package com.dotaschedule.dota_schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PersistentNotificationReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_REFRESH = "com.dotaschedule.dota_schedule.ACTION_REFRESH_PERSISTENT_NOTIFICATION"
    }

    override fun onReceive(context: Context, intent: Intent) {
        PersistentNotificationService.restore(context)
    }
}
