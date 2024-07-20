//
//  NetworkManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/19.
//

import Foundation
import AppKit
import Moya

class Networking<T> where T: APIModel {
    
    var cache: Bool = false
    
    typealias CompletionModelClosure = (_ data: T?, _ cache: Bool) -> Void
    typealias CompletionListClosure = (_ data: [T]?, _ cache: Bool) -> Void
    typealias ErrorClosure = (NetworkError) -> ()
    typealias HandleJSONClosure = ModelGenerator<T>
    
    convenience init(cache: Bool) {
        self.init()
        self.cache = cache
    }
    
    @discardableResult
    func request<R: TargetType>(_ type: R,
                              parseHandler: HandleJSONClosure? = nil,
                              completionListHandler: CompletionListClosure? = nil,
                              completionModelHandler: CompletionModelClosure? = nil,
                              error: ErrorClosure? = nil) -> Cancellable? {
        execute(type, parseHandler: parseHandler, progress: nil, completionListHandler: completionListHandler, completionModelHandler: completionModelHandler, error: error)
    }
    
    private func execute<R: TargetType>(_ type: R,
                                        parseHandler: HandleJSONClosure?,
                                        progress: ProgressBlock? = nil,
                                        completionListHandler: CompletionListClosure?,
                                        completionModelHandler: CompletionModelClosure?,
                                        error: ErrorClosure? = nil) -> Cancellable? {
        
        let provider = provider(type)
        if cache {
            if let dataCachePlugin = type as? DataCachePluginGettableType, let cacheData = dataCachePlugin.cacheData {
                self.handleData(type, parseHandler: parseHandler, data: cacheData, isCache: true, completionListHandler: completionListHandler, completionModelHandler: completionModelHandler)
                return nil
            }
        }
        
        let cancellable = provider.request(type, callbackQueue: DispatchQueue.global(), progress: progress) { response in
            switch response {
            case .success(let resp):
                self.handleData(type, parseHandler: parseHandler, data: resp.data, completionListHandler: completionListHandler, completionModelHandler: completionModelHandler)
            case .failure:
                error!(NetworkError.exception(message: "Server error"))
            }
        }
        return cancellable
    }
    
    private func provider<R: TargetType>(_ type: R) -> MoyaProvider<R> {
        let activityPlugin = NetworkActivityPlugin { (state, targetType) in
            switch state {
                case .began:
                    DispatchQueue.main.async {
                        
                    }
                case .ended:
                    DispatchQueue.main.async {
                        
                    }
            }
        }
        var plugins = [PluginType]()
        let cachePolicyPlugin = CachePolicyPlugin()
        plugins.append(activityPlugin)
        plugins.append(cachePolicyPlugin)
        if self.cache {
            let dataCachePlugin = DataCachePlugin()
            plugins.append(dataCachePlugin)
        }
        let provider = MoyaProvider<R>(plugins: plugins)
        return provider
    }
    
}

extension Networking {
    
    private func handleData<R: TargetType>(_ type: R,
                                           parseHandler: HandleJSONClosure?,
                                           data: Data,
                                           isCache: Bool = false,
                                           completionListHandler: CompletionListClosure?,
                                           completionModelHandler: CompletionModelClosure?) -> Void {
        
        var parseHandler = parseHandler
        if parseHandler == nil {
            parseHandler = ModelGenerator()
        }
        
        switch type.task{
        case .uploadMultipart, .requestParameters:
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let list = json as? [[String: Any]] {
                   let modelList = list.compactMap({parseHandler?.handle($0)})
                    DispatchQueue.main.async {
                        completionListHandler?(modelList, isCache)
                    }
                    
                }
                if let json = json as? [String: Any] {
                   let model = parseHandler?.handle(json)
                    DispatchQueue.main.async {
                        completionModelHandler?(model, isCache)
                    }
                }
            } catch {
#if Debug
                fatalError("unknow error")
#endif
            }
        default:
            ()
        }
    }
}
