//
//  User.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import Foundation

enum AccountType: CaseIterable {
    
    case owner
    case token
    case repo
    case issue
    case comment
    
    var key: String {
        switch self {
        case .owner:
            return "com.githubnote.owner"
        case .repo:
            return "com.githubnote.repo"
        case .token:
            return "com.githubnote.token"
        case .issue:
            return "com.githubnote.issue"
        case .comment:
            return "com.githubnote.comment"   
        }
    }
    
    var value: Any? {
        UserDefaults.value(key)
    }
    
    var title: String {
        switch self {
        case .owner:
            return "owner name"
        case .repo:
            return "repo name"
        case .token:
            return "access token"
        case .comment, .issue:
            return ""
        }
    }
    
    func remove() -> Void {
        UserDefaults.save(value: nil, key: key)
    }
}

struct Account {
    
    static var owner: String {
        guard let value = AccountType.owner.value, let owner = value as? String else { return "" }
        return owner
    }
    
    static var repo: String {
        guard let value = AccountType.repo.value, let repo = value as? String else { return "" }
        return repo
    }
    
    static var accessToken: String {
        guard let value = AccountType.token.value, let token = value as? String else { return "" }
        return token
    }
    
    static var issue: Int {
        guard let value = AccountType.issue.value, let issue = value as? Int else { return 0 }
        return issue
    }
    
    static var comment: Int {
        guard let value = AccountType.owner.value, let comment = value as? Int else { return 0 }
        return comment
    }
    
    static var enble: Bool {
        return !Account.owner.isEmpty && !Account.repo.isEmpty
    }
    
    static func reset() -> Void {
        AccountType.allCases.forEach({$0.remove()})
    }
}
