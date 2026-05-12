import UIKit
import Social
import MobileCoreServices
import Photos

class ShareViewController: SLComposeServiceViewController {
    // IMPORTANT: Match these with your Runner/Info.plist and App Groups configuration
    let hostAppBundleIdentifier = "com.cookedapp.app"
    let sharedContainerIdentifier = "group.com.cookedapp.app"
    let sharedKey = "SharingKey"
    var sharedData: [String] = []

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            if let contents = content.attachments {
                for (index, attachment) in (contents).enumerated() {
                    if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                        attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (data, error) in
                            if let url = data as? URL {
                                self.sharedData.append(url.absoluteString)
                            }
                            if index == (contents.count - 1) {
                                self.saveDataAndExit()
                            }
                        }
                    } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                        attachment.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (data, error) in
                            if let text = data as? String {
                                self.sharedData.append(text)
                            }
                            if index == (contents.count - 1) {
                                self.saveDataAndExit()
                            }
                        }
                    } else {
                        if index == (contents.count - 1) {
                            self.saveDataAndExit()
                        }
                    }
                }
            }
        }
    }

    func saveDataAndExit() {
        let userDefaults = UserDefaults(suiteName: sharedContainerIdentifier)
        userDefaults?.set(sharedData, forKey: sharedKey)
        userDefaults?.synchronize()
        
        // Open the host app
        // Open the host app using the lowercase scheme matching Info.plist
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(URL(string: "cooked://")!, options: [:], completionHandler: nil)
                break
            }
            responder = responder?.next
        }
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
}
