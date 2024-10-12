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
    case userID
    
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
        case .userID:
            return "com.githubnote.userID"
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
        case .comment, .issue, .userID:
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
    
    static var userId: Int {
        guard let value = AccountType.userID.value, let userId = value as? Int else { return 0 }
        return userId
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
        return !Account.owner.isEmpty && !Account.accessToken.isEmpty
    }
    
    static func reset() -> Void {
        AccountType.allCases.forEach({$0.remove()})
    }
}

struct UserModel: APIModelable, Identifiable, Hashable, Equatable {

    var uuid: String?
    
    var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }

    let id: Int?
    let login, nodeId, avatarUrl, gravatarId: String?
    let url, htmlUrl, followersUrl, followingUrl: String?
    let gistsUrl, starredUrl, subscriptionsUrl, organizationsUrl: String?
    let reposUrl, eventsUrl, receivedEventsUrl: String?
    let type: String?
    let siteAdmin: Bool?
    let name, company, blog, location, email, hireable, bio, twitterUsername: String?
    let publicRepos, publicGists, followers, following: Int?
    let createdAt, updatedAt: String?
}
