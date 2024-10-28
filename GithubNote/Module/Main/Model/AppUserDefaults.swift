//
//  AppUserDefaults.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/23.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return defaultValue
            }
            let decoder = JSONDecoder()
            return (try? decoder.decode(T.self, from: data)) ?? defaultValue
        }
        set {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encodedData, forKey: key)
            }
        }
    }
}


struct AppUserDefaults {
    @UserDefault("com.githubnote.repo", defaultValue: nil)
    public static var repo: RepoModel?
        
    @UserDefault("com.githubnote.issue", defaultValue: "")
    public static var issue: String
    
    @UserDefault("com.githubnote.comment", defaultValue: "")
    public static var comment: String
    
    @UserDefault("com.githubnote.accessToken", defaultValue: "")
    public static var accessToken: String

    static func reset() -> Void {
        self.repo = nil
        self.issue = ""
        self.comment = ""
        self.accessToken = ""
    }
}
