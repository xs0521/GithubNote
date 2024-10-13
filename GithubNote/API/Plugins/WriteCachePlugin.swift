//
//  WriteCachePlugin.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/23.
//

import Moya

extension API: WriteCachePluginGettableType {
    
    var writePath: String? {
        cachePath
    }
}

protocol WriteCachePluginGettableType {
    var writePath: String? { get }
}

final class WriteCachePlugin: PluginType {
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Void {
//        guard let dataCachePlugin = target as? WriteCachePluginGettableType, let path = dataCachePlugin.writePath else {
//            return
//        }
//        if case let .success(respond) = result {
//            do {
//                try CacheManager.shared.store.setObject(respond.data, forKey: path)
//            }
//            catch (let error) {
//                print(error)
//            }
//        }
    }
}
