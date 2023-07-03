//
//  Logger.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation
import os.log

public class Logger {
    
    static let redColor     = "\u{001B}[31m"
    static let greenColor   = "\u{001B}[32m"
    static let blueColor    = "\u{001B}[94m"
    static let yellowColor  = "\u{001B}[33m"
    static let resetColor   = "\u{001B}[0m"
    
    static public func d(_ className:String, _ message:String, line: Int = #line){
        os_log("D/Swift: \u{001B}[32m[LOCAL NOTIFICATIONS]\u{001B}[0m %@ (%@:%d)", type: .debug, message, className, line)
    }
    
    static public func e(_ className:String, _ message:String, line: Int = #line){
        os_log("E/Swift: \u{001B}[31m[LOCAL NOTIFICATIONS] %@ (%@:%d)\u{001B}[0m", type: .error, message, className, line)
    }
    
    static public func i(_ className:String, _ message:String, line: Int = #line){
        os_log("I/Swift: \u{001B}[94m[LOCAL NOTIFICATIONS] %@ (%@:%d)\u{001B}[0m", type: .info, message, className, line)
    }
    
    static public func w(_ className:String, _ message:String, line: Int = #line){
        os_log("W/Swift: \u{001B}[33m[LOCAL NOTIFICATIONS] %@ (%@:%d)\u{001B}[0m", type: .fault, message, className, line)
    }
}
