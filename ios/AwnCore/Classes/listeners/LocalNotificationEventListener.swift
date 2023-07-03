//
//  LocalNotificationEventListener.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol LocalNotificationEventListener: AnyObject {
    func onNewNotificationReceived(eventName:String, notificationReceived:NotificationReceived);
}
