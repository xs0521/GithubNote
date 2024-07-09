//
//  CommentModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation

struct Comment: Codable, Identifiable, Hashable, Equatable {
    
    var id = UUID()
    var commentid: Int = 0
    var value: String = ""
    
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.commentid == rhs.commentid
    }
    
    public func defultModel () -> Void {
        
    }
}

struct CommentModel: Codable, Identifiable, Hashable, Equatable {
    
    var id = UUID().uuidString
    
    var selectedCommentItem: Comment?
    var commentList: [Comment] = []
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func defultModel () -> Void {
        
    }
}


