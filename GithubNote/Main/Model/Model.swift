// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - WelcomeElement



// MARK: - Reactions
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

enum UploadType {
    
    case normal
    case sending
    case success
    case fail
    
    var imageName: String {
        switch self {
        case .normal:
            return "icloud.and.arrow.up"
        case .sending:
            return "icloud.and.arrow.up"
        case .success:
            return "checkmark.icloud"
        case .fail:
            return "xmark.icloud"
        }
    }
    
}

enum ContentMaxWidthType {
    case normal
    case mini
}


class ViewModel: ObservableObject {
    
    @Published var issuesModel: IssuesModel
    @Published var commentModel: CommentModel
    
    init(issuesModel: IssuesModel, commentModel: CommentModel) {
        self.issuesModel = issuesModel
        self.commentModel = commentModel
    }
}

