//
//  AppModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/25.
//

import Foundation

struct Reactions: Codable {
    let url: String
    let totalCount, laugh: Int
    let hooray, confused, heart, rocket: Int
    let eyes: Int
    public func defultModel () -> Void {
    }
}

// MARK: - User
struct User: Codable {
    let login: String
    let id: Int
    let nodeId: String
    let avatarUrl: String
    let gravatarId: String
    let url, htmlUrl, followersUrl: String
    let followingUrl, gistsUrl, starredUrl: String
    let subscriptionsUrl, organizationsUrl, reposUrl: String
    let eventsUrl: String
    let receivedEventsUrl: String
    let type: String
    let siteAdmin: Bool
    public func defultModel () -> Void {
    }
}
