//
//  CommentModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation

struct Comment: APIModelable, Identifiable, Hashable, Equatable {
    
    var url, htmlURL, issueURL: String?
    var id: Int?
    var nodeID: String?
    var createdAt, updatedAt: String?
    var body: String?
    var uuid: String?
    
    public var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    public static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


