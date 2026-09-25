package com.app.driver

import android.app.Activity
import android.content.Context
import android.view.View
import com.google.android.libraries.navigation.NavigationApi
import com.google.android.libraries.navigation.NavigationView
import com.google.android.libraries.navigation.Navigator
import com.google.android.libraries.navigation.Waypoint
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * Embeds Google's turn-by-turn Navigation SDK inside the Flutter view tree.
 *
 * Mirrors native's `NavigationMapView.kt`: get a [Navigator] from [NavigationApi],
 * set a single destination, start guidance. `NavigationView` renders its own map,
 * header and footer — nothing else needs to be drawn.
 *
 * One method channel per view instance (`..._$viewId`), matching the pattern
 * Flutter itself recommends for controllable platform views. `setDestination`
 * lets Dart update the target when the booking's next stop changes without
 * tearing the view down (a multi-stop trip advancing to its next leg).
 */
class InAppNavigationView(
    context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    creationParams: Map<*, *>?,
    private val activity: Activity,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val navigationView = NavigationView(context)
    private var navigator: Navigator? = null
    private val channel =
        MethodChannel(messenger, "com.accessible.provider/in_app_navigation_$viewId")

    init {
        channel.setMethodCallHandler(this)

        navigationView.onCreate(null)
        navigationView.onStart()
        navigationView.onResume()

        val lat = creationParams?.get("latitude") as? Double
        val lng = creationParams?.get("longitude") as? Double
        if (lat != null && lng != null) {
            startGuidance(lat, lng)
        }
    }

    private fun startGuidance(latitude: Double, longitude: Double) {
        NavigationApi.getNavigator(
            activity,
            object : NavigationApi.NavigatorListener {
                override fun onNavigatorReady(readyNavigator: Navigator?) {
                    navigator = readyNavigator
                    setDestination(latitude, longitude)
                    readyNavigator?.startGuidance()
                }

                override fun onError(errorCode: Int) {
                    // Nothing to recover to here — the caller falls back to
                    // external navigation if this view never becomes usable.
                }
            },
        )
    }

    private fun setDestination(latitude: Double, longitude: Double) {
        val waypoint = Waypoint.builder().setLatLng(latitude, longitude).build() ?: return
        navigator?.setDestinations(listOf(waypoint))
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setDestination" -> {
                val lat = call.argument<Double>("latitude")
                val lng = call.argument<Double>("longitude")
                if (lat != null && lng != null) setDestination(lat, lng)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = navigationView

    override fun dispose() {
        channel.setMethodCallHandler(null)
        navigator?.stopGuidance()
        navigator?.clearDestinations()
        navigator?.cleanup()
        navigationView.onPause()
        navigationView.onStop()
        navigationView.onDestroy()
    }
}
