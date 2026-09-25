package com.app.driver

import android.util.Log
import io.socket.client.Ack
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.engineio.client.transports.WebSocket
import org.json.JSONObject

/**
 * Mirrors the Kotlin-native SocketManager pattern.
 * All events are wrapped as {"event": eventName, "data": {...}} to match
 * the server's expected format.
 */
class NativeSocketManager(
    private val serverUrl: String,
    private val token: String,
) {
    companion object {
        private const val TAG = "NativeSocketManager"
        private const val KEY_EVENT = "event"
        private const val KEY_DATA = "data"
    }

    private var socket: Socket? = null

    fun connect(onConnected: () -> Unit = {}) {
        try {
            if (socket?.connected() == true) {
                Log.e(TAG, "socket already connected --> id=${socket?.id()}")
                onConnected()
                return
            }

            val options = IO.Options.builder()
                .setTransports(arrayOf(WebSocket.NAME))
                .setExtraHeaders(mapOf("authorization" to listOf(token)))
                .setAuth(mapOf("authorization" to token))
                .build()

            socket = IO.socket(serverUrl, options).also { s ->
                s.on(Socket.EVENT_CONNECT) {
                    Log.e(TAG, "socket connected --> id=${s.id()}")
                    onConnected()
                }
                s.on(Socket.EVENT_CONNECT_ERROR) { args ->
                    Log.e(TAG, "socket connect error --> ${args.firstOrNull()}")
                }
                s.on(Socket.EVENT_DISCONNECT) { args ->
                    Log.e(TAG, "socket disconnected --> reason=${args.firstOrNull()}")
                }
                s.connect()
                Log.e(TAG, "socket connect called")
            }
        } catch (e: Exception) {
            Log.e(TAG, "socket init error --> ${e.message}")
        }
    }

    fun isConnected(): Boolean = socket?.connected() == true

    /**
     * Emits an event wrapped as {"event": eventName, "data": dataJson}.
     * Matches the server's expected format from Kotlin native SocketManager.
     */
    fun emitEvent(
        eventName: String,
        data: JSONObject? = null,
        ackListener: ((ackData: Any?) -> Unit)? = null,
    ) {
        try {
            val eventData = JSONObject().apply {
                put(KEY_EVENT, eventName)
                put(KEY_DATA, data ?: JSONObject())
            }

            Log.e(TAG, "emitEvent --> $eventName | payload --> $eventData")

            if (ackListener != null) {
                socket?.emit(eventName, eventData, Ack { args ->
                    Log.e(TAG, "ack --> eventName=$eventName | ${args.contentToString()}")
                    ackListener(convertAckData(args))
                })
            } else {
                socket?.emit(eventName, eventData)
            }
        } catch (e: Exception) {
            Log.e(TAG, "emitEvent error --> ${e.message}")
        }
    }

    fun disconnect() {
        socket?.disconnect()
        socket = null
        Log.e(TAG, "socket disconnected by manager")
    }

    /**
     * Extracts the inner "data" object from ack args, matching Kotlin native convertData().
     * Server ack format: [eventName, {event, data}] or [{event, data}]
     */
    private fun convertAckData(args: Array<Any?>): Any? {
        if (args.isEmpty()) return null
        return try {
            val raw = if (args.size == 2) args[1]?.toString() else args[0]?.toString()
            val json = JSONObject(raw ?: return null)
            if (args.size == 2) {
                json.put(KEY_EVENT, args[0].toString())
                json.toString()
            } else if (json.has(KEY_DATA)) {
                json[KEY_DATA].toString()
            } else {
                raw
            }
        } catch (e: Exception) {
            args[0]?.toString()
        }
    }
}
