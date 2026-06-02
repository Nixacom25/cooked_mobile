import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
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
