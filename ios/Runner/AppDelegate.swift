import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. Flutter EN PREMIER (obligatoire)
    GeneratedPluginRegistrant.register(with: self)

    // 2. Firebase
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let _ = NSDictionary(contentsOfFile: path) {
      FirebaseApp.configure()
    }

    // 3. Delegate Messaging (obligatoire car FirebaseAppDelegateProxyEnabled = false)
    Messaging.messaging().delegate = self

    // 4. Delegate notifications
    UNUserNotificationCenter.current().delegate = self

    // 5. Enregistrement APNs
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    print("[APNs] ✅ Token APNs reçu et transmis à Firebase")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[APNs] ❌ ERREUR: \(error.localizedDescription)")
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("[FCM] ✅ Token FCM reçu: \(fcmToken ?? "nil")")
  }
}