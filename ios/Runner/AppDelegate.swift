import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must be set before launch finishes (UIScene lifecycle, iOS 27 SDK).
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// UIScene lifecycle: the window / FlutterViewController do not exist yet in didFinishLaunching,
  /// so plugins and channels are registered on the implicit engine here.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let clipboardChannel = FlutterMethodChannel(name: "com.cooked.app/clipboard",
                                                binaryMessenger: engineBridge.applicationRegistrar.messenger())
    clipboardChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "hasWebURL" {
        if #available(iOS 14.0, *) {
          UIPasteboard.general.detectPatterns(for: [.probableWebURL]) { resultPattern in
            DispatchQueue.main.async {
              switch resultPattern {
              case .success(let detected):
                if detected.contains(.probableWebURL) {
                  result(UIPasteboard.general.changeCount)
                } else {
                  result(-1)
                }
              case .failure(_):
                result(-1)
              }
            }
          }
        } else {
          result(UIPasteboard.general.hasURLs ? UIPasteboard.general.changeCount : -1)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10.0, *)
extension AppDelegate {
  
  // Called when a notification is delivered while the app is in the foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification, 
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Show notification even when app is in foreground
    completionHandler([.banner, .list, .sound, .badge])
  }
  
  // Called when user taps on a notification
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse, 
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Pass notification data to Flutter
    NotificationCenter.default.post(name: NSNotification.Name("DidReceiveRemoteNotification"), 
                                    object: nil, 
                                    userInfo: userInfo)
    completionHandler()
  }
}
