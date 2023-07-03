//
//  NSBundleExtension.swift
//  Pods
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation

extension Bundle {
    
    func getBundleName() -> String {
        var finalBundleName = Bundle.main.bundleIdentifier ?? "unknow"
        if(SwiftUtils.isRunningOnExtension()){
            _ = finalBundleName.replaceRegex(#"\.\w+$"#)
        }
        return finalBundleName
    }
}
