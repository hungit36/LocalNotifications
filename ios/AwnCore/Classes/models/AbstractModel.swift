//
//  AbstractModel.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public protocol AbstractModel: AnyObject {
    
    func fromMap(arguments: [String : Any?]?) -> AbstractModel?
    func toMap() -> [String : Any?]

    func validate() throws
}
