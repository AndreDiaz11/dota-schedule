package com.dotaschedule.dota_schedule

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

object PersistentNotificationService {
    private const val PREFS = "pulse_persistent_prefs"
    private const val PREF_MATCHES = "matches"
    private const val CHANNEL_ID = "pulse_next_match"
    private const val NOTIFICATION_ID = 4201
    private const val ALARM_REQUEST_CODE = 4202
    private const val MINUTE = 60_000L
    private const val FIFTEEN_MINUTES = 15L * MINUTE
    private const val DAY = 86_400_000L

    fun sync(context: Context, matchesJson: String) {
        val appContext = context.applicationContext
        prefs(appContext).edit().putString(PREF_MATCHES, matchesJson).apply()
        update(appContext)
    }

    fun stop(context: Context) {
        val appContext = context.applicationContext
        prefs(appContext).edit().remove(PREF_MATCHES).apply()
        cancelRefresh(appContext)
        val manager = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        manager?.cancel(NOTIFICATION_ID)
    }

    fun restore(context: Context) {
        val appContext = context.applicationContext
        if (prefs(appContext).getString(PREF_MATCHES, "").isNullOrEmpty()) return
        update(appContext)
    }

    private fun update(context: Context) {
        val match = nextMatch(parseMatches(prefs(context).getString(PREF_MATCHES, "")))
        if (match == null) {
            stop(context)
            return
        }

        createChannel(context)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        manager?.notify(NOTIFICATION_ID, buildNotification(context, match))
        scheduleNextRefresh(context, match)
    }

    private fun parseMatches(raw: String?): List<TrackedMatch> {
        val matches = mutableListOf<TrackedMatch>()
        if (raw.isNullOrEmpty()) return matches

        try {
            val array = JSONArray(raw)
            for (i in 0 until array.length()) {
                val item = array.getJSONObject(i)
                matches.add(
                    TrackedMatch(
                        teamA = item.optString("teamA"),
                        teamB = item.optString("teamB"),
                        tournament = item.optString("tournament"),
                        startTimeMs = item.optLong("startTimeMs"),
                        isLive = item.optBoolean("isLive", false),
                    )
                )
            }
        } catch (_: Exception) {
        }

        return matches
    }

    private fun nextMatch(matches: List<TrackedMatch>): TrackedMatch? {
        val now = System.currentTimeMillis()
        return matches
            .filter { it.isLive || it.startTimeMs >= now }
            .minByOrNull { if (it.isLive) 0L else it.startTimeMs }
    }

    private fun buildNotification(context: Context, match: TrackedMatch): Notification {
        val title = "${match.teamA} vs ${match.teamB}"
        val text = if (match.isLive) {
            "EN VIVO ahora · ${match.tournament}"
        } else {
            "${countdownText(match.startTimeMs)} · ${match.tournament}"
        }

        val openIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        openIntent?.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            openIntent ?: Intent(),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_pulse)
            .setColor(0xFF4C7FDD.toInt())
            .setContentTitle(title)
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setShowWhen(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_STATUS)

        val notification = builder.build()
        notification.flags = notification.flags or Notification.FLAG_NO_CLEAR or Notification.FLAG_ONGOING_EVENT
        return notification
    }

    private fun countdownText(startTimeMs: Long): String {
        val total = (startTimeMs - System.currentTimeMillis()).coerceAtLeast(0L)
        val days = total / DAY
        val hours = (total % DAY) / 3_600_000L
        val minutes = (total % 3_600_000L) / MINUTE

        return when {
            days == 0L && hours == 0L -> "Empieza en $minutes min"
            days == 0L -> "Empieza en ${hours} h $minutes min"
            else -> "Empieza en $days días, $hours h"
        }
    }

    private fun scheduleNextRefresh(context: Context, match: TrackedMatch) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val pendingIntent = refreshPendingIntent(context)
        val delay = nextTickDelay(match)
        val refreshAt = SystemClock.elapsedRealtime() + delay

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP, refreshAt, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.ELAPSED_REALTIME_WAKEUP, refreshAt, pendingIntent)
            }
        } catch (_: SecurityException) {
            alarmManager.set(AlarmManager.ELAPSED_REALTIME_WAKEUP, refreshAt, pendingIntent)
        }
    }

    private fun cancelRefresh(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        alarmManager.cancel(refreshPendingIntent(context))
    }

    private fun refreshPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, PersistentNotificationReceiver::class.java)
        intent.action = PersistentNotificationReceiver.ACTION_REFRESH
        intent.setPackage(context.packageName)
        return PendingIntent.getBroadcast(
            context,
            ALARM_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun nextTickDelay(match: TrackedMatch): Long {
        if (match.isLive) return FIFTEEN_MINUTES
        val untilStart = match.startTimeMs - System.currentTimeMillis()
        if (untilStart <= 0) return MINUTE
        return untilStart.coerceIn(MINUTE, FIFTEEN_MINUTES)
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Próximo partido favorito",
            NotificationManager.IMPORTANCE_LOW,
        )
        channel.description = "Notificación fija con el próximo partido de tus equipos favoritos"
        channel.setShowBadge(false)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        manager?.createNotificationChannel(channel)
    }

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private data class TrackedMatch(
        val teamA: String,
        val teamB: String,
        val tournament: String,
        val startTimeMs: Long,
        val isLive: Boolean,
    )
}
