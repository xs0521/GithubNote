//
//  UserDefaults+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/4.
//

import Foundation

extension UserDefaults {
    
    static func save(value: Any?, key: String) -> Void {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func value(_ key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }
}
