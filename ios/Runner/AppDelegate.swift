import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase optionnel — ne crashe pas si GoogleService-Info.plist absent
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let _ = NSDictionary(contentsOfFile: path) {
      FirebaseApp.configure()
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
