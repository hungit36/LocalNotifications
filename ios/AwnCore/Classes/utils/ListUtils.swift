//
//  ListUtils.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

class ListUtils {

    public static func isNullOrEmpty(_ list: [AnyObject]?) -> Bool {
        return list?.isEmpty ?? true
    }
}
