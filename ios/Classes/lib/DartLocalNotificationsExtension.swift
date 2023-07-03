//
//  DartLocalNotificationsExtension.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Flutter
import Foundation
import IosAwnCore

public class DartLocalNotificationsExtension: LocalNotificationsExtension {
    
    public static var registrar:FlutterPluginRegistrar?
    
    public static func setRegistrar(flutterEngine:FlutterEngine? = nil){
        if registrar == nil {
//            var finalFlutterEngine = flutterEngine
//            if (finalFlutterEngine == nil){
//                finalFlutterEngine = FlutterEngine(name: "dartLocalServiceExtension", project: nil)
//                finalFlutterEngine!.run(withEntrypoint: nil)
//            }
//
//            registrar = finalFlutterEngine?.registrar(forPlugin: "LocalNotificationsFcm");
        }
    }
    
    public static func initialize() {
        if LocalNotifications.localExtensions != nil {
            return
        }
        LocalNotifications.localExtensions = DarLocalNotificationsExtension()
    }
    
    var initialized:Bool = false
    public func loadExternalExtensions() {
        if initialized {
            return
        }
        
        LocalNotifications.initialize()
        
        if DartLocalNotificationsExtension.registrar != nil {
            FlutterAudioUtils.extendCapabilities(
                usingFlutterRegistrar: DartLocalNotificationsExtension.registrar!)
            
            FlutterBitmapUtils.extendCapabilities(
                usingFlutterRegistrar: DartLocalNotificationsExtension.registrar!)
            
            DartBackgroundExecutor.extendCapabilities(
                usingFlutterRegistrar: DartLocalNotificationsExtension.registrar!)
        }
        
        initialized = true
    }
}
