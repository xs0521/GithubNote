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
        
    @UserDefault("com.githubnote.issue", defaultValue: nil)
    public static var issue: Issue?
    
    @UserDefault("com.githubnote.comment", defaultValue: nil)
    public static var comment: Comment?
    
    @UserDefault("com.githubnote.accessToken", defaultValue: "")
    public static var accessToken: String
    
    @UserDefault("com.githubnote.font.size", defaultValue: 1.0)
    public static var fontSize: CGFloat
    
    @UserDefault("com.githubnote.side.offset.y", defaultValue: 80)
    public static var sideOffsetY: CGFloat

    static func reset() -> Void {
        self.repo = nil
        self.issue = nil
        self.comment = nil
        self.accessToken = ""
    }
}
