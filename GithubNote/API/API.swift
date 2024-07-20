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
            return "/repos/\(Account.owner)/\(repoName)/issues"
        case .comments(let issueId):
            return "/repos/\(Account.owner)/\(Account.repo)/issues/\(issueId)/comments"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .repos:
            return .get
        case .repoIssue:
            return .get
        case .comments:
            return .get
        }
    }
    
    var headers: [String : String]? {
        var params = [String : String]()
        params["Authorization"] = "token \(Account.accessToken)"
        return params
    }
    
    var task: Moya.Task {
        return .requestParameters(parameters: [String : Any](), encoding: URLEncoding.default)
    }
    
}
