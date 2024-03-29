//
//  EnumUtils.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

public class EnumUtils<T: CaseIterable> {

    public static func fromString(_ value: String?) -> T {
        return T.allCases.first{ "\($0)" == (value ?? "") } ?? T.allCases.first!
    }
    
    public static func getEnumOrDefault(reference: String, arguments: [String : Any?]?) -> T {
        let value:String? = arguments?[reference] as? String ?? nil
        let defaultValue:T = fromString(Definitions.initialValues[reference] as? String)

        if(value == nil) { return defaultValue }
        let founded:T = fromString(value)
        return founded
    }
}
