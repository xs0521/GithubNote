//
//  RepoModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation

// MARK: - License
struct License: Codable {
    let key, name, spdxID: String?
    let url: String?
    let nodeID: String?
    public func defultModel () -> Void {
    }
}

// MARK: - Permissions
struct Permissions: Codable {
    let admin, maintain, push, triage: Bool?
    let pull: Bool?
    public func defultModel () -> Void {
    }
}

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
    let nodeID, name, fullName: String?
    let repoPrivate: Bool?
    let owner: User?
    let htmlURL: String?
    let description: String?
    let fork: Bool?
    let url: String?
    let forksURL: String?
    let keysURL, collaboratorsURL: String?
    let teamsURL, hooksURL: String?
    let issueEventsURL: String?
    let eventsURL: String?
    let assigneesURL, branchesURL: String?
    let tagsURL: String?
    let blobsURL, gitTagsURL, gitRefsURL, treesURL: String?
    let statusesURL: String?
    let languagesURL, stargazersURL, contributorsURL, subscribersURL: String?
    let subscriptionURL: String?
    let commitsURL, gitCommitsURL, commentsURL, issueCommentURL: String?
    let contentsURL, compareURL: String?
    let mergesURL: String?
    let archiveURL: String?
    let downloadsURL: String?
    let issuesURL, pullsURL, milestonesURL, notificationsURL: String?
    let labelsURL, releasesURL: String?
    let deploymentsURL: String?
    let createdAt, updatedAt, pushedAt: String?
    let gitURL, sshURL: String?
    let cloneURL: String?
    let svnURL: String?
    let homepage: String?
    let size, stargazersCount, watchersCount: Int?
    let language: String?
    let hasIssues, hasProjects, hasDownloads, hasWiki: Bool?
    let hasPages, hasDiscussions: Bool?
    let forksCount: Int?
    let archived, disabled: Bool?
    let openIssuesCount: Int?
    let license: License?
    let allowForking, isTemplate, webCommitSignoffRequired: Bool?
    let visibility: String?
    let forks, openIssues, watchers: Int?
    let defaultBranch: String?
    let permissions: Permissions?
    
    init(id: Int? = nil, nodeID: String? = nil, name: String? = nil, fullName: String? = nil, repoPrivate: Bool? = nil, owner: User? = nil, htmlURL: String? = nil, description: String? = nil, fork: Bool? = nil, url: String? = nil, forksURL: String? = nil, keysURL: String? = nil, collaboratorsURL: String? = nil, teamsURL: String? = nil, hooksURL: String? = nil, issueEventsURL: String? = nil, eventsURL: String? = nil, assigneesURL: String? = nil, branchesURL: String? = nil, tagsURL: String? = nil, blobsURL: String? = nil, gitTagsURL: String? = nil, gitRefsURL: String? = nil, treesURL: String? = nil, statusesURL: String? = nil, languagesURL: String? = nil, stargazersURL: String? = nil, contributorsURL: String? = nil, subscribersURL: String? = nil, subscriptionURL: String? = nil, commitsURL: String? = nil, gitCommitsURL: String? = nil, commentsURL: String? = nil, issueCommentURL: String? = nil, contentsURL: String? = nil, compareURL: String? = nil, mergesURL: String? = nil, archiveURL: String? = nil, downloadsURL: String? = nil, issuesURL: String? = nil, pullsURL: String? = nil, milestonesURL: String? = nil, notificationsURL: String? = nil, labelsURL: String? = nil, releasesURL: String? = nil, deploymentsURL: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, pushedAt: String? = nil, gitURL: String? = nil, sshURL: String? = nil, cloneURL: String? = nil, svnURL: String? = nil, homepage: String? = nil, size: Int? = nil, stargazersCount: Int? = nil, watchersCount: Int? = nil, language: String? = nil, hasIssues: Bool? = nil, hasProjects: Bool? = nil, hasDownloads: Bool? = nil, hasWiki: Bool? = nil, hasPages: Bool? = nil, hasDiscussions: Bool? = nil, forksCount: Int? = nil, archived: Bool? = nil, disabled: Bool? = nil, openIssuesCount: Int? = nil, license: License? = nil, allowForking: Bool? = nil, isTemplate: Bool? = nil, webCommitSignoffRequired: Bool? = nil, visibility: String? = nil, forks: Int? = nil, openIssues: Int? = nil, watchers: Int? = nil, defaultBranch: String? = nil, permissions: Permissions? = nil) {
        self.id = id
        self.nodeID = nodeID
        self.name = name
        self.fullName = fullName
        self.repoPrivate = repoPrivate
        self.owner = owner
        self.htmlURL = htmlURL
        self.description = description
        self.fork = fork
        self.url = url
        self.forksURL = forksURL
        self.keysURL = keysURL
        self.collaboratorsURL = collaboratorsURL
        self.teamsURL = teamsURL
        self.hooksURL = hooksURL
        self.issueEventsURL = issueEventsURL
        self.eventsURL = eventsURL
        self.assigneesURL = assigneesURL
        self.branchesURL = branchesURL
        self.tagsURL = tagsURL
        self.blobsURL = blobsURL
        self.gitTagsURL = gitTagsURL
        self.gitRefsURL = gitRefsURL
        self.treesURL = treesURL
        self.statusesURL = statusesURL
        self.languagesURL = languagesURL
        self.stargazersURL = stargazersURL
        self.contributorsURL = contributorsURL
        self.subscribersURL = subscribersURL
        self.subscriptionURL = subscriptionURL
        self.commitsURL = commitsURL
        self.gitCommitsURL = gitCommitsURL
        self.commentsURL = commentsURL
        self.issueCommentURL = issueCommentURL
        self.contentsURL = contentsURL
        self.compareURL = compareURL
        self.mergesURL = mergesURL
        self.archiveURL = archiveURL
        self.downloadsURL = downloadsURL
        self.issuesURL = issuesURL
        self.pullsURL = pullsURL
        self.milestonesURL = milestonesURL
        self.notificationsURL = notificationsURL
        self.labelsURL = labelsURL
        self.releasesURL = releasesURL
        self.deploymentsURL = deploymentsURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pushedAt = pushedAt
        self.gitURL = gitURL
        self.sshURL = sshURL
        self.cloneURL = cloneURL
        self.svnURL = svnURL
        self.homepage = homepage
        self.size = size
        self.stargazersCount = stargazersCount
        self.watchersCount = watchersCount
        self.language = language
        self.hasIssues = hasIssues
        self.hasProjects = hasProjects
        self.hasDownloads = hasDownloads
        self.hasWiki = hasWiki
        self.hasPages = hasPages
        self.hasDiscussions = hasDiscussions
        self.forksCount = forksCount
        self.archived = archived
        self.disabled = disabled
        self.openIssuesCount = openIssuesCount
        self.license = license
        self.allowForking = allowForking
        self.isTemplate = isTemplate
        self.webCommitSignoffRequired = webCommitSignoffRequired
        self.visibility = visibility
        self.forks = forks
        self.openIssues = openIssues
        self.watchers = watchers
        self.defaultBranch = defaultBranch
        self.permissions = permissions
    }

    
    public func defultModel () -> Void {
    }
}


