//
//  NotificationScheduleModel.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol NotificationScheduleModel : AbstractModel {
    
    /// Initial reference date from schedule
    var createdDate:RealDateTime? { get set }
    /// Initial reference date from schedule
    var timeZone:TimeZone? { get set }
    
    func getUNNotificationTrigger() -> UNNotificationTrigger?
    
    func hasNextValidDate() -> Bool
    func getNextValidDate() -> RealDateTime?
}
