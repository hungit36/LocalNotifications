//
//  SwiftUtils.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation
public class SwiftUtils{
    
    private static var _isExtension:Bool?
    
    public static func isRunningOnExtension() -> Bool {
//    #if ACTION_EXTENSION
//        return true
//    #else
//        return false
//    #endif
        if _isExtension == nil {
            _isExtension = Bundle.main.bundlePath.hasSuffix(".appex")
        }
        return _isExtension!
    }
}
