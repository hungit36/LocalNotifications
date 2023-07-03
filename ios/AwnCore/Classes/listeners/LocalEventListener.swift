//
//  LocalEventListener.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol LocalEventListener: AnyObject {
    func onNewLocalEvent(eventType:String, content:[String: Any?]);
}
