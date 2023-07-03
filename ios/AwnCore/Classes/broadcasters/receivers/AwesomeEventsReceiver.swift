//
//  LocalEventsReceiver.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public class LocalEventsReceiver {
    private let TAG = "LocalEventsReceiver"
    
    // **************************** SINGLETON PATTERN *************************************
    
    static var instance:LocalEventsReceiver?
    public static var shared:LocalEventsReceiver {
        get {
            LocalEventsReceiver.instance =
                LocalEventsReceiver.instance ?? localEventsReceiver()
            return LocalEventsReceiver.instance!
        }
    }
    private init(){}
    
    
    // **************************** OBSERVER PATTERN **************************************
    
    private lazy var notificationEventListeners = [LocalNotificationEventListener]()
    
    public func subscribeOnNotificationEvents(listener:LocalNotificationEventListener) -> Self {
        notificationEventListeners.append(listener)
        
        if LocalNotifications.debug {
            Logger.d(TAG, String(describing: listener) + " subscribed to receive notification events")
        }
        return self
    }
    
    public func unsubscribeOnNotificationEvents(listener:LocalNotificationEventListener) -> Self {
        if let index = notificationEventListeners.firstIndex(where: {$0 === listener}) {
            notificationEventListeners.remove(at: index)
            if LocalNotifications.debug {
                Logger.d(TAG, String(describing: listener) + " unsubscribed from notification events")
            }
        }
        return self
    }
    
    private func notifyNotificationEvent(
        named eventName: String,
        with notificationReceived: NotificationReceived
    ){
        if LocalNotifications.debug && actionEventListeners.isEmpty {
            Logger.e(TAG, "New event \(eventName) ignored, as there is no listeners waiting for new notification events")
        }
        
        for listener in notificationEventListeners {
            listener.onNewNotificationReceived(
                eventName: eventName,
                notificationReceived: notificationReceived)
        }
    }
    
    
    // **************************** OBSERVER PATTERN **************************************
    
    private lazy var actionEventListeners = [LocalActionEventListener]()
    
    public func subscribeOnActionEvents(listener:LocalActionEventListener) {
        actionEventListeners.append(listener)
        
        if LocalNotifications.debug {
            Logger.d(TAG, String(describing: listener) + " subscribed to receive action events")
        }
    }
    
    public func unsubscribeOnActionEvents(listener:LocalActionEventListener) {
        if let index = actionEventListeners.firstIndex(where: {$0 === listener}) {
            actionEventListeners.remove(at: index)
            if LocalNotifications.debug {
                Logger.d(TAG, String(describing: listener) + " unsubscribed from action events")
            }
        }
    }
    
    private func notifyActionEvent(
        named eventName: String,
        with actionReceived: ActionReceived
    ){
        if LocalNotifications.debug && actionEventListeners.isEmpty {
            Logger.e(TAG, "New event \(eventName) ignored, as there is no listeners waiting for new action events")
        }
        
        var interrupted:Bool = false
        for listener in actionEventListeners {
            interrupted = interrupted || listener.onNewActionReceivedWithInterruption(
                                                    fromEventNamed: eventName,
                                                    withActionReceived: actionReceived)
        }
        
        if interrupted {
            return
        }
        
        for listener in actionEventListeners {
            listener.onNewActionReceived(
                fromEventNamed: eventName,
                withActionReceived: actionReceived)
        }
    }
    
    // **************************** OBSERVER PATTERN **************************************
    
    
    public func addNotificationEvent(
        named eventName: String,
        with notificationReceived: NotificationReceived
    ){
        if notificationEventListeners.isEmpty {
            if LocalNotifications.debug {
                Logger.e(TAG, "New event \(eventName) ignored, as there is no listeners waiting for new notification events")
            }
            return
        }
        
        do {
            switch eventName {
                
                case Definitions.BROADCAST_CREATED_NOTIFICATION:
                    try onBroadcast(notificationCreated: notificationReceived)
                    return
                    
                case Definitions.BROADCAST_DISPLAYED_NOTIFICATION:
                    try onBroadcast(notificationDisplayed: notificationReceived)
                    return
                    
                default:
                    if LocalNotifications.debug {
                        Logger.d(TAG, "Received unknown notification event: '\(eventName)'")
                    }
            }
        } catch {
            Logger.e(TAG, error.localizedDescription)
        }
    }
    
    public func addActionEvent(
        named eventName: String,
        with actionReceived: ActionReceived
    ){
        if notificationEventListeners.isEmpty {
            if LocalNotifications.debug {
                Logger.e(TAG, "New event \(eventName) ignored, as there is no listeners waiting for new action events")
            }
            return
        }
        
        do {
            switch eventName {
                
                case Definitions.BROADCAST_DEFAULT_ACTION:
                    try onBroadcast(defaultAction: actionReceived)
                    return
                    
                case Definitions.BROADCAST_DISMISSED_NOTIFICATION:
                    try onBroadcast(dismissAction: actionReceived)
                    return
                    
                case Definitions.BROADCAST_SILENT_ACTION:
                    try onBroadcast(silentAction: actionReceived)
                    return
                    
                case Definitions.BROADCAST_BACKGROUND_ACTION:
                    try onBroadcast(backgroundAction: actionReceived)
                    return
                    
                default:
                    if LocalNotifications.debug {
                        Logger.d(TAG, "Received unknown notification event: '\(eventName)'")
                    }
            }
        }
        catch {
            Logger.e(TAG, error.localizedDescription)
        }
    }
    
    private func onBroadcast(notificationCreated notificationReceived: NotificationReceived) throws {
        try notificationReceived.validate()
        
        if LocalNotifications.debug {
            Logger.d(TAG, "New notification creation event")
        }
        
        notifyNotificationEvent(
            named: Definitions.EVENT_NOTIFICATION_CREATED,
            with: notificationReceived)
    }
    
    private func onBroadcast(notificationDisplayed notificationReceived: NotificationReceived) throws {
        try notificationReceived.validate()
        
        if LocalNotifications.debug {
            Logger.d(TAG, "New notification display event")
        }
        
        notifyNotificationEvent(
            named: Definitions.EVENT_NOTIFICATION_DISPLAYED,
            with: notificationReceived)
    }
    
    private func onBroadcast(defaultAction actionReceived: ActionReceived) throws {
        try actionReceived.validate()
        
        if LocalNotifications.debug {
            Logger.d(TAG, "New notification action event")
        }
        
        notifyActionEvent(
            named: Definitions.EVENT_DEFAULT_ACTION,
            with: actionReceived)
    }
    
    private func onBroadcast(dismissAction actionReceived: ActionReceived) throws {
        try actionReceived.validate()
        
        if LocalNotifications.debug {
            Logger.d(TAG, "New notification dismiss event")
        }
        
        notifyActionEvent(
            named: Definitions.EVENT_NOTIFICATION_DISMISSED,
            with: actionReceived)
    }
    
    private func onBroadcast(silentAction actionReceived: ActionReceived) throws {
        try actionReceived.validate()
        
        if LocalNotifications.debug {
            Logger.d(TAG, "New silent action event")
        }
        
        notifyActionEvent(
            named: Definitions.EVENT_SILENT_ACTION,
            with: actionReceived)
    }
    
    private func onBroadcast(backgroundAction actionReceived: ActionReceived) throws {
        try actionReceived.validate()
        
        if LocalNotifications.debug {
            Logger.d(TAG, "New background silent action event")
        }
        
        notifyActionEvent(
            named: Definitions.EVENT_SILENT_ACTION,
            with: actionReceived)
    }
}
