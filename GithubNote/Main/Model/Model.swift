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
            return "arrow.up.circle.fill"
        case .sending:
            return "arrow.up.circle.badge.clock"
        case .success:
            return "checkmark.circle.fill"
        case .fail:
            return "checkmark.circle.badge.xmark.fill"
        }
    }
    
}

struct AppConst {
    static var markdown: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd HH:mm:ss"// 自定义时间格式
        let time = dateformatter.string(from: Date())
        return "### note \(time)"
    }
    static let issueItemHeight: CGFloat = 30
    static let commentItemHeight: CGFloat = 30
}


class ViewModel: ObservableObject {
    
    @Published var issuesModel: IssuesModel
    @Published var commentModel: CommentModel
    
    init(issuesModel: IssuesModel, commentModel: CommentModel) {
        self.issuesModel = issuesModel
        self.commentModel = commentModel
    }
}

