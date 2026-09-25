import Flutter
import UIKit
import CoreLocation
import GoogleMaps
import GoogleNavigation

/// Embeds Google's turn-by-turn Navigation SDK inside the Flutter view tree.
///
/// Mirrors native's `GoogleMapManager.startGoogleNavigation`: create a
/// navigation session, enable it on a `GMSMapView`, set a single destination,
/// start guidance. The map view's own header/footer render the turn-by-turn
/// UI — nothing else needs to be drawn on the Dart side.
class InAppNavigationView: NSObject, FlutterPlatformView {
    private let mapView: GMSMapView
    private var navigationSession: GMSNavigationSession?
    private var channel: FlutterMethodChannel?

    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15)
        mapView = GMSMapView(frame: frame, camera: camera)
        super.init()

        channel = FlutterMethodChannel(
            name: "com.accessible.provider/in_app_navigation_\(viewId)",
            binaryMessenger: messenger
        )
        channel?.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }

        let destination = args as? [String: Any]
        startGuidance(
            latitude: destination?["latitude"] as? Double,
            longitude: destination?["longitude"] as? Double
        )
    }

    private func startGuidance(latitude: Double?, longitude: Double?) {
        GMSNavigationServices.showTermsAndConditionsDialogIfNeeded(
            withCompanyName: InAppNavigationView.appDisplayName()
        ) { [weak self] accepted in
            guard accepted, let self = self else { return }

            // The terms callback is not guaranteed to land on the main queue,
            // and these are all UIKit properties — set off-main they silently
            // fail to apply (the camera stops following while the SDK-drawn
            // header still renders). Native hops to main here for the same
            // reason.
            DispatchQueue.main.async {
                if self.navigationSession == nil {
                    self.navigationSession = GMSNavigationServices.createNavigationSession()
                }
                guard let session = self.navigationSession else { return }

                session.travelMode = .driving
                guard self.mapView.enableNavigation(with: session) else { return }

                self.mapView.settings.isNavigationHeaderEnabled = true
                self.mapView.settings.isNavigationFooterEnabled = true
                self.mapView.settings.compassButton = true
                self.mapView.settings.showsDestinationMarkers = false
                self.mapView.shouldDisplaySpeedometer = true
                self.mapView.shouldDisplaySpeedLimit = true
                self.mapView.cameraMode = .following
                // Native also recolors the header/footer to match its own theme
                // (navigationHeaderPrimaryBackgroundColor etc., using app fonts
                // that don't exist on this side) and adds itself as a
                // GMSNavigatorListener to react to turn events elsewhere in its
                // UI. Neither is needed for the header/footer to render and
                // guide — left as Google's defaults; add if a future screen
                // needs to react to navigation events itself.

                if let lat = latitude, let lng = longitude {
                    self.setDestination(latitude: lat, longitude: lng)
                }
            }
        }
    }

    private func setDestination(latitude: Double, longitude: Double) {
        guard let navigator = navigationSession?.navigator else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        guard let waypoint = GMSNavigationWaypoint(location: coordinate, title: "") else { return }

        navigator.setDestinations([waypoint]) { status in
            guard status == .OK else { return }
            navigator.isGuidanceActive = true
            navigator.voiceGuidance = .alertsAndGuidance
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setDestination":
            if let params = call.arguments as? [String: Any],
               let lat = params["latitude"] as? Double,
               let lng = params["longitude"] as? Double {
                setDestination(latitude: lat, longitude: lng)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func view() -> UIView {
        return mapView
    }

    /// Read from the bundle rather than hardcoded — this codebase is white-labelled
    /// across multiple branded apps, and the ToS dialog must show each one's own name.
    private static func appDisplayName() -> String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? "Driver"
    }

    deinit {
        // iOS has no stopGuidance() — that's the Android Navigator API. Here
        // guidance is a property, and native's stopGoogleNavigation() simply
        // turns navigation off on the map view.
        navigationSession?.navigator?.isGuidanceActive = false
        navigationSession?.navigator?.clearDestinations()
        mapView.isNavigationEnabled = false
        channel?.setMethodCallHandler(nil)
    }
}
