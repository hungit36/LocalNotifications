//
//  BooleanUtils.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

class BooleanUtils {
    
    public static func getValue(value: Any?, defaultValue: Bool?) -> Bool {
        return value as! Bool? ?? defaultValue ?? false
    }
    
}
