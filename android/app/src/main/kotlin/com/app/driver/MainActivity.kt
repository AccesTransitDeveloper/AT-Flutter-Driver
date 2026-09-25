package com.app.driver

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val methodChannelName = "com.accessible.provider/location_service"
    private val eventChannelName = "com.accessible.provider/location_updates"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    // Save server URL so LocationService can use it after app is killed
                    val serverUrl = call.argument<String>("serverUrl") ?: ""
                    if (serverUrl.isNotEmpty()) {
                        getSharedPreferences("native_service_prefs", Context.MODE_PRIVATE)
                            .edit().putString("server_url", serverUrl).apply()
                    }
                    val intent = Intent(this, LocationService::class.java).apply {
                        action = LocationService.ACTION_START
                    }
                    startForegroundService(intent)
                    result.success(true)
                }
                "stopService" -> {
                    val intent = Intent(this, LocationService::class.java).apply {
                        action = LocationService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(true)
                }
                "isRunning" -> {
                    result.success(LocationService.isRunning)
                }
                "setHasBooking" -> {
                    val value = call.argument<Boolean>("value") ?: false
                    LocationService.hasBooking = value
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            eventChannelName,
        ).setStreamHandler(LocationEventStreamHandler())

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.accessible.provider/in_app_navigation",
            InAppNavigationViewFactory(flutterEngine.dartExecutor.binaryMessenger, this),
        )
    }
}
