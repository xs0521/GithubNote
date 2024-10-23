//
//  AppUserDefaults.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/23.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

public struct AppUserDefaults {
    @UserDefault("com.githubnote.repo", defaultValue: "")
    public static var repo: String
        
    @UserDefault("com.githubnote.issue", defaultValue: "")
    public static var issue: String
    
    @UserDefault("com.githubnote.comment", defaultValue: "")
    public static var comment: String
    
    @UserDefault("com.githubnote.accessToken", defaultValue: "")
    public static var accessToken: String

    static func reset() -> Void {
        self.repo = ""
        self.issue = ""
        self.comment = ""
        self.accessToken = ""
    }
}
