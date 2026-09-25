import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    guard
      let googleMapsAPIKey = Bundle.main.object(
        forInfoDictionaryKey: "GoogleMapsAPIKey"
      ) as? String,
      !googleMapsAPIKey.isEmpty,
      !googleMapsAPIKey.contains("$(")
    else {
      fatalError(
        "GOOGLE_MAPS_API_KEY must be configured in ios/Flutter/Secrets.xcconfig"
      )
    }
    GMSServices.provideAPIKey(googleMapsAPIKey)
    GeneratedPluginRegistrant.register(with: self)

    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    UIApplication.shared.applicationIconBadgeNumber = 0

    // Register location MethodChannel and EventChannel
    let controller = window?.rootViewController as! FlutterViewController
    let messenger = controller.binaryMessenger

    let methodChannel = FlutterMethodChannel(
      name: "com.accessible.provider/location_service",
      binaryMessenger: messenger
    )

    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "startService":
        LocationService.shared.startUpdates()
        result(true)
      case "stopService":
        LocationService.shared.stopUpdates()
        result(true)
      case "isRunning":
        result(LocationService.shared.isRunning)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let secureFilesChannel = FlutterMethodChannel(
      name: "com.accessible.provider/secure_files",
      binaryMessenger: messenger
    )
    secureFilesChannel.setMethodCallHandler { (call, result) in
      guard call.method == "excludeFromBackup",
            let arguments = call.arguments as? [String: Any],
            let path = arguments["path"] as? String else {
        result(FlutterMethodNotImplemented)
        return
      }

      var url = URL(fileURLWithPath: path)
      do {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "BACKUP_EXCLUSION_FAILED",
            message: "Unable to exclude AT AI Driver files from iCloud backup.",
            details: error.localizedDescription
          )
        )
      }
    }

    let eventChannel = FlutterEventChannel(
      name: "com.accessible.provider/location_updates",
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(LocationEventStreamHandler.shared)

    registrar(forPlugin: "InAppNavigationView")?.register(
      InAppNavigationViewFactory(messenger: messenger),
      withId: "com.accessible.provider/in_app_navigation"
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Pass APNS token to Firebase
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Forward remote notifications to Firebase
  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Messaging.messaging().appDidReceiveMessage(userInfo)
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM Token: \(fcmToken ?? "nil")")
  }
}
