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

//    enum CodingKeys: String, CodingKey {
//        case url
//        case htmlURL = "html_url"
//        case issueURL = "issue_url"
//        case id
//        case nodeID = "node_id"
//        case user
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case body
//    }
    
    public var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    public static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(   url: String? = nil,
            htmlURL: String? = nil,
            issueURL: String? = nil,
            id: Int? = nil,
            nodeID: String? = nil,
            createdAt: String? = nil,
            updatedAt: String? = nil,
            uuid: String? = nil,
            body: String? = nil) {
            self.url = url
            self.htmlURL = htmlURL
            self.issueURL = issueURL
            self.id = id
            self.nodeID = nodeID
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.body = body
            self.uuid = UUID().uuidString
        }
    
    func newComment(_ content: String, _ id: Int) -> Comment {
        var item = Comment()
        item.id = id
        item.body = content
        return item
    }
}


