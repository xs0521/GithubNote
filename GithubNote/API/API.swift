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
    case repoIssue(repoName: String)
    case comments(issueId: Int)
    case newComment(issueId: Int, body: String)
    case updateComment(commentId: Int, body: String)
    case newIssue(title: String, body: String)
    case repoImages
    
    
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
        case .repoIssue(let repoName):
            return "/repos/\(owner)/\(repoName)/issues"
        case .comments(let issueId), .newComment(let issueId, _):
            return "/repos/\(owner)/\(selectRepo)/issues/\(issueId)/comments"
        case .updateComment(let commentId, _):
            return "/repos/\(owner)/\(selectRepo)/issues/comments/\(commentId)"
        case .newIssue:
            return "/repos/\(owner)/\(selectRepo)/issues"
        case .repoImages:
            return "/repos/\(owner)/\(selectRepo)/contents/images"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .newComment, .newIssue, .updateComment:
            return .post
        default:
            return .get
        }
    }
    
    var headers: [String : String]? {
        var params = [String : String]()
        params["Authorization"] = "token \(accessToken)"
        if case .newIssue = self {
            params["Accept"] = "application/vnd.github.v3+json"
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
        default: break
        }
        let encoding: ParameterEncoding = method == .post ? JSONEncoding.default : URLEncoding.default
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
