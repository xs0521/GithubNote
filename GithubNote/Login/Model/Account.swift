//
//  User.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import Foundation

enum AccountType {
    
    case owner
    case repo
    case token
    
    var key: String {
        switch self {
        case .owner:
            return "com.githubnote.owner"
        case .repo:
            return "com.githubnote.repo"
        case .token:
            return "com.githubnote.token"
        }
    }
    
    var value: String? {
        UserDefaults.value(key) as? String
    }
    
    var title: String {
        switch self {
        case .owner:
            return "input owner name"
        case .repo:
            return "input repo name"
        case .token:
            return "input token"
        }
    }
}

struct Account {
    
    static var owner: String {
        return AccountType.owner.value ?? ""
    }
    
    static var repo: String {
        return AccountType.repo.value ?? ""
    }
    
    static var accessToken: String {
        return AccountType.token.value ?? ""
    }
    
    static var enble: Bool {
        return !Account.owner.isEmpty && !Account.repo.isEmpty && !Account.accessToken.isEmpty
    }
}
