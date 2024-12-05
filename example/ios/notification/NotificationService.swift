//
//  NotificationService.swift
//  notification
//
//  Created by rymin on 10/29/24.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            // 새로 추가된 코드
            if bestAttemptContent.userInfo["client_id"] as? String == "loplat" {
                if let urlString = bestAttemptContent.userInfo["image_uri"] as? String,
                   let url = URL(string: urlString),
                   let imageData = NSData(contentsOf: url),
                   let attachment = UNNotificationAttachment.create(
                    imageFileIdentifier: "loplatAdvertisement.jpg",
                    data: imageData,
                    options: nil
                   ) {
                    if let index = bestAttemptContent.attachments.firstIndex(where: {
                        $0.identifier == "loplatAdvertisement.jpg"
                    }) {
                        bestAttemptContent.attachments.remove(at: index)
                    }
                    bestAttemptContent.attachments.append(attachment)
                }
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

@available(iOS 10.0, *)
extension UNNotificationAttachment {
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject: AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let fileURLPath = NSURL(fileURLWithPath: NSTemporaryDirectory())
        
        guard let tmpSubFolderURL = fileURLPath.appendingPathComponent(tmpSubFolderName, isDirectory: true) else {
            return nil
        }
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL, options: [])
            return try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
        } catch {
            return nil
        }
    }
}
