//
//  User.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import Foundation

enum AccountType: CaseIterable {
    
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
            return "owner name"
        case .repo:
            return "repo name"
        case .token:
            return "access token"
        }
    }
    
    func remove() -> Void {
        UserDefaults.save(value: nil, key: key)
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
    
    static func reset() -> Void {
        AccountType.allCases.forEach({$0.remove()})
    }
}

extension Account {
    
    static let kEditMode = "com.github.note.edit.mode.key"
    
    
    static var editMode: ContentMaxWidthType {
        guard let min = UserDefaults.value(kEditMode) as? Bool else { return .normal }
        return min ? .mini : .normal
    }
    
    static func saveEditMode(_ mode: ContentMaxWidthType) -> Void {
        UserDefaults.save(value: mode == .mini, key: kEditMode)
    }
}
