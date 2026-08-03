package com.dotaschedule.dota_schedule

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "pulse/persistent_notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "sync" -> {
                    val matchesJson = call.argument<String>("matchesJson") ?: "[]"
                    val leadMinutes = call.argument<Int>("leadMinutes") ?: 15
                    PersistentNotificationService.sync(applicationContext, matchesJson, leadMinutes)
                    result.success(true)
                }
                "stop" -> {
                    PersistentNotificationService.stop(applicationContext)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
