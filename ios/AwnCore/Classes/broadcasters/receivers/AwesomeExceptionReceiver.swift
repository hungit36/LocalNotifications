//
//  LocalExceptionReceiver.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public class LocalExceptionReceiver  {
    
    let TAG = "LocalExceptionReceiver"
    
    // ******************** SINGLETON PATTERN *****************************
    
    static var instance:LocalExceptionReceiver?
    public static var shared:LocalExceptionReceiver {
        get {
            LocalExceptionReceiver.instance =
                LocalExceptionReceiver.instance ?? LocalExceptionReceiver()
            return LocalExceptionReceiver.instance!
        }
    }
    private init(){}
    
    
    // ******************* OBSERVER PATTERN *******************************
    
    private lazy var eventListeners = [LocalExceptionListener]()
    
    public func subscribeOnNotificationEvents(listener:LocalExceptionListener) -> Self {
        eventListeners.append(listener)
        
        if LocalNotifications.debug {
            Logger.d(TAG, String(describing: listener) + " subscribed to receive exception events")
        }
        return self
    }
    
    public func unsubscribeOnNotificationEvents(listener:LocalExceptionListener) -> Self {
        if let index = eventListeners.firstIndex(where: {$0 === listener}) {
            eventListeners.remove(at: index)
            if LocalNotifications.debug {
                Logger.d(TAG, String(describing: listener) + " unsubscribed from exception events")
            }
        }
        return self
    }
    
    public func notifyExceptionEvent(
        fromClassName className:String,
        withLocalException localException:LocalNotificationsException
    ){
        Logger.e(TAG, lcoalException.message)
        for listener in eventListeners {
            listener.onNewLocalException(
                fromClassName: className,
                withLocalException: localException)
        }
    }
    
    
}
