//
//  IssuesModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation

enum IssueState: String, Codable {
    case open = "open"
    case closed = "closed"
}

struct Issue: APIModelable, Identifiable, Hashable, Equatable {
    
    var uuid: String?
    
    var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    let id: Int?
    let url: String?
    let repositoryUrl: String?
    let number: Int?
    var title: String?
    let body: String?
    let state: IssueState?
    
    func filter() -> Bool {
        return state == .open
    }
}
