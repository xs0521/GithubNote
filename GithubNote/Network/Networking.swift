//
//  NetworkManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/19.
//

import Foundation
import AppKit
import Moya

class Networking<T> where T: APIModelable {
    
    typealias CompletionModelClosure = (_ data: [T]?, _ cache: Bool, _ code: Int) -> Void
    typealias ErrorClosure = (NetworkError) -> ()
    typealias HandleJSONClosure = ModelGenerator<T>
    
    @discardableResult
    func request<R: TargetType>(_ type: R,
                                writeCache: Bool = true,
                                readCache: Bool = true,
                                parseHandler: HandleJSONClosure? = nil,
                                completionModelHandler: CompletionModelClosure? = nil,
                                error: ErrorClosure? = nil) -> Cancellable? {
        execute(type, writeCache: writeCache, readCache: readCache, parseHandler: parseHandler, progress: nil, completionModelHandler: completionModelHandler, error: error)
    }
    
    private func execute<R: TargetType>(_ type: R,
                                        writeCache: Bool = true,
                                        readCache: Bool = true,
                                        parseHandler: HandleJSONClosure?,
                                        progress: ProgressBlock? = nil,
                                        completionModelHandler: CompletionModelClosure?,
                                        error: ErrorClosure? = nil) -> Cancellable? {
        
        let provider = provider(type, writeCache: writeCache)
        if readCache {
            if let api = type as? API, let cacheData = api.cacheData {
                self.handleData(type, parseHandler: parseHandler, data: cacheData, isCache: true, completionModelHandler: completionModelHandler)
                return nil
            }
        }
        
        let cancellable = provider.request(type, callbackQueue: DispatchQueue.global(), progress: progress) { response in
            switch response {
            case .success(let resp):
                self.handleData(type, parseHandler: parseHandler, respone: resp, data: resp.data, completionModelHandler: completionModelHandler)
            case .failure(let error):
                completionModelHandler?(nil, false, error.errorCode)
            }
        }
        return cancellable
    }
    
    private func provider<R: TargetType>(_ type: R, writeCache: Bool) -> MoyaProvider<R> {
        
        var plugins = [PluginType]()
        
        func cachePolicyPlugin() -> Void {
            let plugin = CachePolicyPlugin()
            plugins.append(plugin)
        }
        
        func networkActivityPlugin() -> Void {
            let plugin = NetworkActivityPlugin { (_, _) in }
            plugins.append(plugin)
        }
        
        func networkLoggerPlugin() -> Void {
            let plugin = NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
            plugins.append(plugin)
        }
        
        func writeCachePlugin() -> Void {
            let plugin = WriteCachePlugin()
            plugins.append(plugin)
        }
        
        networkActivityPlugin()
        cachePolicyPlugin()
        networkLoggerPlugin()
        if writeCache {
            writeCachePlugin()
        }

        let provider = MoyaProvider<R>(plugins: plugins)
        return provider
    }
    
}

extension Networking {
    
    private func handleData<R: TargetType>(_ type: R,
                                           parseHandler: HandleJSONClosure?,
                                           respone: Response? = nil,
                                           data: Data,
                                           isCache: Bool = false,
                                           completionModelHandler: CompletionModelClosure?) -> Void {
        
        let parseHandler = parseHandler ?? ModelGenerator()
        let code = (respone != nil) ? respone!.statusCode : MessageCode.success.rawValue
        
        func callBack(_ data: [T]?, _ cache: Bool, _ code: Int) -> Void {
            DispatchQueue.main.async {
                completionModelHandler?(data, isCache, code)
            }
        }
        
        switch type.task{
        case .uploadMultipart, .requestParameters:
            do {
                if data.isEmpty {
                    callBack(nil, isCache, code)
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let list = json as? [[String: Any]] {
                    let modelList = list.compactMap({parseHandler.handle($0)})
                    callBack(modelList, isCache, code)
                } else if let json = json as? [String: Any] {
                    if let model = parseHandler.handle(json) {
                        callBack([model], isCache, code)
                    } else {
                        callBack(nil, isCache, code)
                    }
                } else {
                    callBack(nil, isCache, code)
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
