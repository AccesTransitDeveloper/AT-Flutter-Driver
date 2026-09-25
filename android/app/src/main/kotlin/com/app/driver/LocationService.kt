package com.app.driver

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

class LocationService : Service() {

    companion object {
        const val ACTION_START = "ACTION_START_SERVICE"
        const val ACTION_STOP = "ACTION_STOP_SERVICE"
        const val CHANNEL_ID = "location_service_channel"
        const val NOTIFICATION_ID = 1111
        private const val TAG = "LocationService"

        var isRunning = false
            private set

        /// Set from MainActivity via MethodChannel when a booking starts/ends.
        var hasBooking = false
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var socketManager: NativeSocketManager? = null
    private lateinit var locationDb: LocationDb
    private val kalmanFilter = KalmanFilter()
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var pendingLocation: SocketLocationData? = null

    // ── Lifecycle ────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        Log.e(TAG, "service onCreate")
        locationDb = LocationDb(this)
        connectSocket()
        setupLocationCallback()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startLocationUpdates()
            ACTION_STOP -> stopLocationUpdates()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        if (isRunning) {
            fusedLocationClient.removeLocationUpdates(locationCallback)
            isRunning = false
        }
        socketManager?.disconnect()
        socketManager = null
        serviceScope.cancel()
        super.onDestroy()
    }

    // ── Socket ───────────────────────────────────────────────────────────────

    private fun connectSocket() {
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val token = flutterPrefs.getString("flutter.authorization", "") ?: ""

        val nativePrefs = getSharedPreferences("native_service_prefs", Context.MODE_PRIVATE)
        val serverUrl = nativePrefs.getString("server_url", "") ?: ""

        Log.e(TAG, "connectSocket --> url=$serverUrl token=${if (token.isNotEmpty()) token.take(20) + "..." else "EMPTY"}")

        if (token.isEmpty() || serverUrl.isEmpty()) {
            Log.w(TAG, "Cannot connect socket: token or serverUrl empty")
            return
        }

        // Deliberately NOT opening a socket here.
        //
        // The server binds one socket per driver. This service used to open a
        // second connection that never emitted SIGN_UP, so it superseded the
        // Dart socket without being registered against the driver — locations
        // sent on it were dropped and the customer's
        // `api/location/{bookingId}` stayed empty ("Booking location not
        // found"). Native Android has no such split: its LocationService
        // shares the single signed-up socket.
        //
        // Locations still reach Flutter over LocationEventStreamHandler, and
        // HomeViewModel emits DRIVER_LIVE_LOCATION on the signed-up socket.
        Log.e(TAG, "socket intentionally not opened; Dart owns the connection")
    }

    // ── Location ─────────────────────────────────────────────────────────────

    private fun setupLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                result.lastLocation?.let { location ->
                    Log.e(TAG, "location --> $location")

                    if (location.isFromMockProvider) {
                        Log.e(TAG, "mock location detected, skipping")
                        return
                    }

                    val (filteredLat, filteredLng) = kalmanFilter.process(
                        lat = location.latitude,
                        lng = location.longitude,
                        accuracy = location.accuracy,
                        timestampMs = location.time,
                    )

                    Log.e(TAG, "kalman filtered --> lat=$filteredLat lng=$filteredLng | hasBooking=$hasBooking | socketConnected=${socketManager?.isConnected()}")

                    // Emit filtered location to Flutter UI via EventChannel
                    LocationEventStreamHandler.sendLocation(
                        hashMapOf(
                            "type" to "location",
                            "latitude" to filteredLat,
                            "longitude" to filteredLng,
                            "speed" to location.speed.toDouble(),
                            "bearing" to location.bearing.toDouble(),
                            "time" to location.time,
                            "accuracy" to location.accuracy.toDouble(),
                        )
                    )

                    // Send filtered location to server
                    val socketLoc = SocketLocationData(
                        lat = filteredLat,
                        lng = filteredLng,
                        time = location.time,
                        speed = location.speed,
                        bearing = location.bearing,
                    )
                    proceedNextForLocation(socketLoc)
                }
            }
        }
    }

    private fun startLocationUpdates() {
        if (isRunning) return

        if (androidx.core.content.ContextCompat.checkSelfPermission(
                this, android.Manifest.permission.ACCESS_FINE_LOCATION
            ) != android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "Location permission not granted")
            return
        }

        createNotificationChannel()
        val notification = createNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 5000L).apply {
            setMinUpdateIntervalMillis(2000L)
            setMinUpdateDistanceMeters(10f)
        }.build()

        try {
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
            isRunning = true
            Log.e(TAG, "location updates started")
        } catch (e: SecurityException) {
            Log.e(TAG, "Missing location permission: ${e.message}")
            stopSelf()
        }
    }

    private fun stopLocationUpdates() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
        socketManager?.disconnect()
        socketManager = null
        isRunning = false
        serviceScope.launch { locationDb.deleteAll() }
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        Log.d(TAG, "Location updates stopped")
    }

    // ── Server Communication ─────────────────────────────────────────────────

    private fun proceedNextForLocation(location: SocketLocationData) {
        // Queue location if socket isn't connected yet (will be sent on connect)
        if (socketManager?.isConnected() != true) {
            pendingLocation = location
            return
        }

        if (hasBooking) {
            serviceScope.launch {
                locationDb.insert(location)
                Log.e(TAG, "data inserted in db --> lat=${location.lat} lng=${location.lng} time=${location.time}")
                updateLocationToServer(listOf(location))
            }
        } else {
            updateLocationToServer(listOf(location))
        }
    }

    private fun updateLocationToServer(currentLocations: List<SocketLocationData>) {
        // Emitting happens in Dart on the signed-up socket — see connectSocket().
        // Buffered locations stay in the DB so a future background-capable
        // implementation can still flush them.
        if (socketManager?.isConnected() != true) {
            return
        }

        serviceScope.launch {
            val finalList = mutableListOf<SocketLocationData>()
            if (hasBooking) {
                val dbList = locationDb.getAll()
                finalList.addAll(dbList)
                Log.e(TAG, "loaded from db --> ${dbList.size} location(s)")
            }
            currentLocations.forEach { loc ->
                if (finalList.none { it.time == loc.time }) finalList.add(loc)
            }
            if (finalList.isEmpty()) return@launch

            val locationsArray = JSONArray()
            finalList.forEach { loc ->
                locationsArray.put(JSONObject().apply {
                    put("latitude", loc.lat)
                    put("longitude", loc.lng)
                    put("time", loc.time)
                    put("speed", loc.speed)
                    put("bearing", loc.bearing)
                })
            }
            val data = JSONObject().put("locations", locationsArray)

            Log.e(TAG, "update location to server --> ${finalList.size} location(s) | data --> $data")

            socketManager?.emitEvent(
                eventName = "DRIVER_LIVE_LOCATION",
                data = data,
                ackListener = { ackData ->
                    try {
                        val ackJson = when (ackData) {
                            is JSONObject -> ackData
                            is String -> JSONObject(ackData)
                            else -> JSONObject(ackData.toString())
                        }

                        Log.e(TAG, "ack received --> $ackJson")

                        // Forward ack to Flutter UI as EventChannel event
                        LocationEventStreamHandler.sendLocation(
                            hashMapOf(
                                "type" to "ack",
                                "data" to ackJson.toString(),
                            )
                        )

                        // Delete buffered locations that server has confirmed
                        if (hasBooking && ackJson.has("time")) {
                            val ackTime = ackJson.getLong("time")
                            serviceScope.launch {
                                locationDb.deleteUpTo(ackTime)
                                Log.e(TAG, "data deleted from db --> time <= $ackTime")
                            }
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "ack parse error --> ${e.message}")
                    }
                }
            )
        }
    }

    // ── Notification ─────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Location Tracking",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Used for tracking driver location"
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AT Driver")
            .setContentText("Tracking your location")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}

// ── Data ─────────────────────────────────────────────────────────────────────

data class SocketLocationData(
    val lat: Double,
    val lng: Double,
    val time: Long,
    val speed: Float,
    val bearing: Float,
)

// ── Kalman Filter ─────────────────────────────────────────────────────────────

class KalmanFilter {
    private var variance = -1.0
    private var lat = 0.0
    private var lng = 0.0

    fun process(lat: Double, lng: Double, accuracy: Float, timestampMs: Long): Pair<Double, Double> {
        if (variance < 0) {
            this.lat = lat
            this.lng = lng
            variance = (accuracy * accuracy).toDouble()
        } else {
            val k = variance / (variance + accuracy * accuracy)
            this.lat += k * (lat - this.lat)
            this.lng += k * (lng - this.lng)
            variance = (1 - k) * variance
        }
        return Pair(this.lat, this.lng)
    }
}

// ── SQLite Location Buffer ────────────────────────────────────────────────────

class LocationDb(context: Context) : SQLiteOpenHelper(context, "driver_locations.db", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """CREATE TABLE locations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                time INTEGER NOT NULL,
                speed REAL NOT NULL,
                bearing REAL NOT NULL
            )"""
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS locations")
        onCreate(db)
    }

    fun insert(loc: SocketLocationData) {
        writableDatabase.insert("locations", null, ContentValues().apply {
            put("latitude", loc.lat)
            put("longitude", loc.lng)
            put("time", loc.time)
            put("speed", loc.speed)
            put("bearing", loc.bearing)
        })
    }

    fun getAll(): List<SocketLocationData> {
        val list = mutableListOf<SocketLocationData>()
        readableDatabase.query("locations", null, null, null, null, null, "time ASC").use { c ->
            while (c.moveToNext()) {
                list.add(
                    SocketLocationData(
                        lat = c.getDouble(c.getColumnIndexOrThrow("latitude")),
                        lng = c.getDouble(c.getColumnIndexOrThrow("longitude")),
                        time = c.getLong(c.getColumnIndexOrThrow("time")),
                        speed = c.getFloat(c.getColumnIndexOrThrow("speed")),
                        bearing = c.getFloat(c.getColumnIndexOrThrow("bearing")),
                    )
                )
            }
        }
        return list
    }

    fun deleteUpTo(time: Long) {
        writableDatabase.delete("locations", "time <= ?", arrayOf(time.toString()))
    }

    fun deleteAll() {
        writableDatabase.delete("locations", null, null)
    }
}
