import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure notification center delegate for iOS
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let clipboardChannel = FlutterMethodChannel(name: "com.cooked.app/clipboard",
                                              binaryMessenger: controller.binaryMessenger)
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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return super.application(app, open: url, options: options)
  }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  
  // Called when a notification is delivered while the app is in the foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification, 
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Show notification even when app is in foreground
    completionHandler([.banner, .sound, .badge])
  }
  
  // Called when user taps on a notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
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
