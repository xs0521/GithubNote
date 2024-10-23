//
//  GithubAPI.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation
import Moya

private let kMaxPage = 100

enum API {
    
    case user(_ userName: String)
    case repos(page: Int)
    case createRepo(repoName: String)
    case repoIssues(repoName: String, page: Int)
    case comments(issueId: Int, page: Int)
    case newComment(issueId: Int, body: String)
    case updateComment(commentId: Int, body: String)
    case deleteComment(commentId: Int)
    case newIssue(title: String, body: String)
    case updateIssue(issueId: Int, state: IssueState, title: String, body: String)
    case createImagesDirectory
    case repoImages
    case updateImage(imageBase64: String, fileName: String)
    case deleteImage(filePath: String, sha: String)
    
    
    var owner: String { UserManager.shared.user?.login ?? "" }
    var selectRepo: String { AppUserDefaults.repo }
    var accessToken: String { AppUserDefaults.accessToken }
}

extension API: TargetType {
    
    var baseURL: URL {
        URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .user(let userName):
            return "/users/\(userName)"
        case .repos:
            return accessToken.isEmpty ? "/users/\(owner)/repos" : "/user/repos"
        case .createRepo:
            return "/user/repos"
        case .repoIssues(let repoName, _):
            return "/repos/\(owner)/\(repoName)/issues"
        case .comments(let issueId, _), .newComment(let issueId, _):
            return "/repos/\(owner)/\(selectRepo)/issues/\(issueId)/comments"
        case .updateComment(let commentId, _):
            return "/repos/\(owner)/\(selectRepo)/issues/comments/\(commentId)"
        case .deleteComment(let commentId):
            return "/repos/\(owner)/\(selectRepo)/issues/comments/\(commentId)"
        case .newIssue:
            return "/repos/\(owner)/\(selectRepo)/issues"
        case .updateIssue(let issueId, _, _, _):
            return "/repos/\(owner)/\(selectRepo)/issues/\(issueId)"
        case .createImagesDirectory:
            return "repos/\(owner)/\(selectRepo)/contents/githubnote/images.txt"
        case .repoImages:
            return "/repos/\(owner)/\(selectRepo)/contents/githubnote"
        case .updateImage(_, let fileName):
            return "/repos/\(owner)/\(selectRepo)/contents/githubnote/\(fileName)"
        case .deleteImage(let filePath, _):
            return "/repos/\(owner)/\(selectRepo)/contents/\(filePath)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createRepo, .newComment, .newIssue, .updateComment:
            return .post
        case .updateIssue:
            return .patch
        case .deleteComment, .deleteImage:
            return .delete
        case .createImagesDirectory, .updateImage:
            return .put
        default:
            return .get
        }
    }
    
    var headers: [String : String]? {
        var params = [String : String]()
        if !accessToken.isEmpty {
            params["Authorization"] = "token \(accessToken)"
        }
        switch self {
        case .createRepo, .newIssue, .deleteComment, .updateImage, .deleteImage:
            params["Accept"] = "application/vnd.github.v3+json"
        default: break
        }
        return params
    }
    
    var task: Moya.Task {
        var parameters = [String : Any]()
        switch self {
        case .repos(let page),
             .repoIssues(_, let page),
             .comments(_, let page):
            parameters["per_page"] = kMaxPage
            parameters["page"] = page
        case .createRepo(let repoName):
            parameters["name"] = repoName
            parameters["content"] = "This is your new repository"
            parameters["private"] = true
        case .newComment(_, let body):
            parameters["body"] = body
        case .newIssue(let title, let body):
            parameters["title"] = title
            parameters["body"] = body
        case .updateComment(_, let body):
            parameters["body"] = body
        case .updateIssue(_, let state, let title, let body):
            parameters["state"] = state.rawValue
            parameters["title"] = title
            parameters["body"] = body
        case .createImagesDirectory:
            parameters["message"] = "Create new directory"
            parameters["content"] = "Q3JlYXRlIGEgbmV3IGRpcmVjdG9yeQ=="
            parameters["branch"] = "main"
        case .updateImage(let imageBase64, let fileName):
            parameters["message"] = "upload image \(fileName)"
            parameters["content"] = imageBase64
            parameters["branch"] = "main"
        case .deleteImage(let filePath, let sha):
            parameters["message"] = "delete image \(filePath.split(separator: "/").last ?? "")"
            parameters["sha"] = sha
            parameters["branch"] = "main"
        default: break
        }
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
}
