//
//  Log.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation
import os.log

class Log {
    
    public static func i(_ tag:String, _ message:String, file:String = #file, function:String = #function, line:Int = #line){
        os_log("%@ %@:%d %@", type: .error, tag, function, line, message)
    }
    
    public static func e(_ tag:String, _ message:String, file:String = #file, function:String = #function, line:Int = #line){
        os_log("%@ %@:%d %@", type: .error, tag, function, line, message)
    }
    
    public static func d(_ tag:String, _ message:String, file:String = #file, function:String = #function, line:Int = #line){
        if(LocalNotifications.debug){
            os_log("%@ %@:%d %@", type: .error, tag, function, line, message)
        }
    }
    
}
