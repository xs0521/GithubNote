//
//  DataCachePlugin.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Moya

extension API: DataCachePluginGettableType {
    
    var cacheData: Data? {
        guard let cachePath = cachePath else { return nil }
        do {
            let value = try CacheManager.shared.store.object(forKey: cachePath)
            return value
        } catch (let error) {
            print(error)
        }
        return nil
    }
    
    var cachePath: String? {
        let value = Account.owner + path
        return value.MD5()
    }
    
}

protocol DataCachePluginGettableType {
    var cachePath: String? { get }
    var cacheData: Data? { get }
}

final class DataCachePlugin: PluginType {
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Void {
        guard let dataCachePlugin = target as? DataCachePluginGettableType, let cachePath = dataCachePlugin.cachePath else {
            return
        }
        if case let .success(respond) = result {
            do {
                try CacheManager.shared.store.setObject(respond.data, forKey: cachePath)
            }
            catch (let error) {
                print(error)
            }
        }
    }
}
