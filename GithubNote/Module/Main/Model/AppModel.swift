//
//  AppModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/25.
//

import Foundation

struct Reactions: Codable {
    let url: String?
    let totalCount, laugh: Int?
    let hooray, confused, heart, rocket: Int?
    let eyes: Int?
}

struct PushCommitModel: APIModelable, Identifiable, Hashable, Equatable {
    
    var id: String?
    var uuid: String?
    
    let content: PushContent?
    let commit: PushCommit?
    
    public var identifier: String {
        return "\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    public static func == (lhs: PushCommitModel, rhs: PushCommitModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

// MARK: - Commit
struct PushCommit: Codable {
    let sha, nodeID: String?
    let url, htmlURL: String?
//    let author, committer: User?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case sha
        case nodeID = "node_id"
        case url, message
        case htmlURL = "html_url"
//        case author, committer
    }
}

// MARK: - Content
struct PushContent: Codable {
    let name, path, sha: String?
    let size: Int?
    let url, htmlURL: String?
    let gitURL: String?
    let downloadURL: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url
        case htmlURL = "html_url"
        case gitURL = "git_url"
        case downloadURL = "download_url"
        case type
    }
    
}
