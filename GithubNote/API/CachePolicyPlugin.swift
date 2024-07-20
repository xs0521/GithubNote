//
//  CachePolicyPlugin.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Moya

extension API: CachePolicyGettableType {
    var cachePolicy: URLRequest.CachePolicy? {
        switch self {
        case .repoIssue:
            return .reloadIgnoringLocalCacheData
        default:
            return .useProtocolCachePolicy
        }
    }
}

protocol CachePolicyGettableType {
    var cachePolicy: URLRequest.CachePolicy? { get }
}

final class CachePolicyPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let policyGettable = target as? CachePolicyGettableType, let policy = policyGettable.cachePolicy else {
            return request
        }
        var mutableRequest = request
        mutableRequest.cachePolicy = policy
        return mutableRequest
    }
}
