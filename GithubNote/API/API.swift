//
//  GithubAPI.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation
import Moya

enum API {
    
    case repos
    case repoIssues(repoName: String)
    case comments(issueId: Int)
    case newComment(issueId: Int, body: String)
    case updateComment(commentId: Int, body: String)
    case deleteComment(commentId: Int)
    case newIssue(title: String, body: String)
    case updateIssue(issueId: Int, state: IssueState, title: String, body: String)
    case createImagesDirectory
    case repoImages
    case updateImage(imageBase64: String, fileName: String)
    
    
    var owner: String { Account.owner }
    var selectRepo: String { Account.repo }
    var accessToken: String { Account.accessToken }
    
    var cachePath: String? {
        let value = Account.owner + path
        return value.MD5()
    }
    
    var cacheData: Data? {
        guard let cachePath = cachePath else { return nil }
        do {
            let exit = try CacheManager.shared.store.existsObject(forKey: cachePath)
            if exit {
                let value = try CacheManager.shared.store.object(forKey: cachePath)
                return value
            }
        } catch (let error) {
            print(error)
        }
        return nil
    }
}

extension API: TargetType {
    
    var baseURL: URL {
        URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .repos:
            return "/user/repos"
        case .repoIssues(let repoName):
            return "/repos/\(owner)/\(repoName)/issues"
        case .comments(let issueId), .newComment(let issueId, _):
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
            return "repos/\(owner)/\(selectRepo)/contents/images/images.txt"
        case .repoImages:
            return "/repos/\(owner)/\(selectRepo)/contents/images"
        case .updateImage(_, let fileName):
            return "repos/\(owner)/\(selectRepo)/contents/images/\(fileName)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .newComment, .newIssue, .updateComment:
            return .post
        case .updateIssue:
            return .patch
        case .deleteComment:
            return .delete
        case .createImagesDirectory, .updateImage:
            return .put
        default:
            return .get
        }
    }
    
    var headers: [String : String]? {
        var params = [String : String]()
        params["Authorization"] = "token \(accessToken)"
        switch self {
        case .newIssue, .deleteComment, .updateImage:
            params["Accept"] = "application/vnd.github.v3+json"
        default: break
        }
        return params
    }
    
    var task: Moya.Task {
        var parameters = [String : Any]()
        switch self {
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
        default: break
        }
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
}
