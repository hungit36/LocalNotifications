//
//  LocalActionEventListener.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol LocalActionEventListener: AnyObject {
    func onNewActionReceived(fromEventNamed eventName:String, withActionReceived actionReceived:ActionReceived)
    func onNewActionReceivedWithInterruption(fromEventNamed eventName:String, withActionReceived actionReceived:ActionReceived) -> Bool
}
