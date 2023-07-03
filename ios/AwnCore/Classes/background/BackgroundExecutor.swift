//
//  DartBackgroundExecutor.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//
import Foundation

public protocol BackgroundExecutor {
    
    init()
    
    var isRunning:Bool { get }
    var isNotRunning:Bool { get }
        
    func runBackgroundProcess(
        silentActionRequest: SilentActionRequest,
        dartCallbackHandle:Int64,
        silentCallbackHandle:Int64
    )
}
