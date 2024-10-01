//
//  RepoModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation

struct RepoModel: APIModelable, Identifiable, Hashable, Equatable {
    
    var uuid: String?
    
    var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: RepoModel, rhs: RepoModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int?
    let name, fullName: String?
    let createdAt, updatedAt, pushedAt: String?
    let repoPrivate: Bool?
}


