//
//  LocalLifeCycleEventListener.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol LocalLifeCycleEventListener: AnyObject {
    func onNewLifeCycleEvent(lifeCycle:NotificationLifeCycle)
}
