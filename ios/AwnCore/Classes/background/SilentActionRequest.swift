//
//  SilentDataRequest.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//
import Foundation

public class SilentActionRequest {
    public let actionReceived: ActionReceived
    public let handler: (Bool) -> ()
    
    init(actionReceived:ActionReceived, handler: @escaping (Bool) -> ()){
        self.actionReceived = actionReceived
        self.handler = handler
    }
}
