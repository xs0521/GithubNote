//
//  IssuesModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation

struct Issue: Codable, Identifiable, Hashable, Equatable {
    
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    let url, repositoryUrl: String?
    let labelsUrl: String?
    let commentsUrl, eventsUrl, htmlUrl: String?
    let id: Int?
    let nodeid: String?
    let number: Int?
    let title: String?
    let user: User?
    let state: String?
    let locked: Bool?
    let comments: Int?
    let createdAt, updatedAt: String?
    let authorAssociation: String?
    let body: String?
    let reactions: Reactions?
    let timelineUrl: String?
    
    init(url: String? = nil, repositoryUrl: String? = nil, labelsUrl: String? = nil, commentsUrl: String? = nil, eventsUrl: String? = nil, htmlUrl: String? = nil, id: Int? = nil, nodeid: String? = nil, number: Int? = nil, title: String? = nil, user: User? = nil, state: String? = nil, locked: Bool? = nil, comments: Int? = nil, createdAt: String? = nil, updatedAt: String? = nil, authorAssociation: String? = nil, body: String? = nil, reactions: Reactions? = nil, timelineUrl: String? = nil) {
        // 在初始化方法中设置属性的初始值
        self.url = url
        self.repositoryUrl = repositoryUrl
        self.labelsUrl = labelsUrl
        self.commentsUrl = commentsUrl
        self.eventsUrl = eventsUrl
        self.htmlUrl = htmlUrl
        self.id = id
        self.nodeid = nodeid
        self.number = number
        self.title = title
        self.user = user
        self.state = state
        self.locked = locked
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.authorAssociation = authorAssociation
        self.body = body
        self.reactions = reactions
        self.timelineUrl = timelineUrl
    }
    
    public func defultModel () -> Void {
    }
}

struct IssuesModel: Codable, Identifiable, Hashable, Equatable {
    
    var id = UUID().uuidString
    
    var issueList: [Issue] = []
    var selectedSideBarItem: Issue = Issue()
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public static func == (lhs: IssuesModel, rhs: IssuesModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func defultModel () -> Void {
    }
}
