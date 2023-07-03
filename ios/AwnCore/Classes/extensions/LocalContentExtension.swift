//
//  LocalContentExtension.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import Foundation

// https://stackoverflow.com/questions/39882188/how-do-you-create-a-notification-content-extension-without-using-a-storyboard

@available(iOS 10.0, *)
open class LocalContentExtension: UIViewController, UNNotificationContentExtension {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    public func didReceive(_ notification: UNNotification) {
    }
}
