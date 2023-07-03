//
//  BroadcastSender.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

class BroadcastSender {
    
    private let TAG = "BroadcastSender"
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:BroadcastSender?
    public static var shared:BroadcastSender {
        get {
            BroadcastSender.instance =
                BroadcastSender.instance ?? BroadcastSender()
            return BroadcastSender.instance!
        }
    }
    private init(){}
    
    // ********************************************************
    
    public func sendBroadcast(
        notificationCreated notificationReceived: NotificationReceived,
        whenFinished completionHandler: @escaping (Bool) -> Void
    ){
        if SwiftUtils.isRunningOnExtension() || LifeCycleManager.shared.currentLifeCycle == .AppKilled {
            CreatedManager.saveCreated(received: notificationReceived)
        }
        else {
            LocalEventsReceiver
                .shared
                .addNotificationEvent(
                    named: Definitions.BROADCAST_CREATED_NOTIFICATION,
                    with: notificationReceived)
        }
        
        completionHandler(true)
    }
    
    public func sendBroadcast(
        notificationDisplayed notificationReceived: NotificationReceived,
        whenFinished completionHandler: @escaping (Bool) -> Void
    ){
        if SwiftUtils.isRunningOnExtension() || LifeCycleManager.shared.currentLifeCycle == .AppKilled {
            DisplayedManager.saveDisplayed(received: notificationReceived)
        }
        else {
            LocalEventsReceiver
                .shared
                .addNotificationEvent(
                    named: Definitions.BROADCAST_DISPLAYED_NOTIFICATION,
                    with: notificationReceived)
        }
        
        DefaultsManager
            .shared
            .registerLastDisplayedDate()
        
        completionHandler(true)
    }
    
    public func sendBroadcast(
        actionReceived: ActionReceived,
        whenFinished completionHandler: @escaping (Bool, Error?) -> Void
    ){
        if !ActionManager.recovered { //LifeCycleManager.shared.currentLifeCycle == .AppKilled
            ActionManager.saveAction(received: actionReceived)
            Logger.i(TAG, "action saved")
        }
        else {
            LocalEventsReceiver
                .shared
                .addActionEvent(
                    named: Definitions.BROADCAST_DEFAULT_ACTION,
                    with: actionReceived)
            Logger.i(TAG, "action broadcasted")
        }
        
        completionHandler(true, nil)
    }
    
    public func sendBroadcast(
        notificationDismissed actionReceived: ActionReceived,
        whenFinished completionHandler: @escaping (Bool, Error?) -> Void
    ){
        if LifeCycleManager.shared.currentLifeCycle == .AppKilled {
            DismissedManager.saveDismissed(received: actionReceived)
        }
        else {
            LocalEventsReceiver
                .shared
                .addActionEvent(
                    named: Definitions.BROADCAST_DISMISSED_NOTIFICATION,
                    with: actionReceived)
        }
        
        completionHandler(true, nil)
    }
    
    public func sendBroadcast(
        silentAction: ActionReceived,
        whenFinished completionHandler: @escaping (Bool, Error?) -> Void
    ){
        LocalEventsReceiver
            .shared
            .addActionEvent(
                named: Definitions.BROADCAST_SILENT_ACTION,
                with: silentAction)
        
        completionHandler(true, nil)
    }
    
    public func sendBroadcast(
        backgroundAction: ActionReceived,
        whenFinished completionHandler: @escaping (Bool, Error?) -> Void
    ){
        LocalEventsReceiver
            .shared
            .addActionEvent(
                named: Definitions.BROADCAST_BACKGROUND_ACTION,
                with: backgroundAction)
        
        completionHandler(true, nil)
    }
    
    public func enqueue(
        silentAction actionReceived: ActionReceived,
        whenFinished completionHandler: @escaping (Bool, Error?) -> Void
    ){
        BackgroundService
            .shared
            .enqueue(
                SilentBackgroundAction: actionReceived,
                withCompletionHandler: completionHandler)
    }
    
    public func enqueue(
        silentBackgroundAction actionReceived: ActionReceived,
        whenFinished completionHandler: @escaping (Bool, Error?) -> Void
    ){
        BackgroundService
            .shared
            .enqueue(
                SilentBackgroundAction: actionReceived,
                withCompletionHandler: completionHandler)
    }
    
}
