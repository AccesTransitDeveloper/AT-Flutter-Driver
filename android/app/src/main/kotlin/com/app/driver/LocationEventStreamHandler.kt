package com.app.driver

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class LocationEventStreamHandler : EventChannel.StreamHandler {

    companion object {
        private var eventSink: EventChannel.EventSink? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        fun sendLocation(locationData: HashMap<String, Any>) {
            mainHandler.post {
                eventSink?.success(locationData)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
