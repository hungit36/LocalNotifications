//
//  LocalExceptionListener.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol LocalExceptionListener: AnyObject {
    func onNewLocalException(
        fromClassName className:String,
        withLocalException locaException:LocalNotificationsException)
}
