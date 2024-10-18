//
//  NetworkManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/19.
//

import Foundation
#if MOBILE
import UIKit
#else
import AppKit
#endif
import Moya


private let line = "\n########################################"

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
    
    @discardableResult
    func uploadImage<R: TargetType>(_ type: R,
                                writeCache: Bool = false,
                                readCache: Bool = false,
                                parseHandler: HandleJSONClosure? = nil,
                                progress: ProgressBlock? = nil,
                                completionModelHandler: CompletionModelClosure? = nil,
                                error: ErrorClosure? = nil) -> Cancellable? {
        execute(type, writeCache: writeCache, readCache: readCache, parseHandler: parseHandler, progress: progress, completionModelHandler: completionModelHandler, error: error)
    }
    
    private func execute<R: TargetType>(_ type: R,
                                        writeCache: Bool = true,
                                        readCache: Bool = true,
                                        parseHandler: HandleJSONClosure?,
                                        progress: ProgressBlock? = nil,
                                        completionModelHandler: CompletionModelClosure?,
                                        error: ErrorClosure? = nil) -> Cancellable? {
        
        let provider = provider(type, writeCache: writeCache)
#if false
        if readCache {
            if let api = type as? API, let cacheData = api.cacheData {
                self.handleData(type, parseHandler: parseHandler, data: cacheData, isCache: true, completionModelHandler: completionModelHandler)
                return nil
            }
        }
#endif
        
        let targetType = type as! API
        
        // 记录请求开始时间
        let startTime = Date()
        // 合成日志的字符串
        
        var logMessage = line + """
                        \nurl: \(type.baseURL)\(type.path)
                        method: \(type.method.rawValue)
            """
        
        if case let .requestParameters(parameters, _) = targetType.task {
            // 请求参数 (如果有的话)
            if parameters.count > 0 {
                logMessage += "\nparams: \(parameters)"
            } else {
                logMessage += "\nparams: null"
            }
        }
        
        let cancellable = provider.request(type, callbackQueue: DispatchQueue.global(), progress: progress) { response in
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            // 增加请求耗时
            logMessage += "\nduration: \(String(format: "%.2f", duration)) s"
            
            switch response {
            case .success(let resp):
                if resp.statusCode == MessageCode.credentialsError.rawValue {
                    "#request# code \(MessageCode.credentialsError.rawValue)".logE()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name.logoutForceNotification, object: nil)
                    }
                    return
                }
                self.handleData(type,
                                parseHandler: parseHandler,
                                respone: resp,
                                data: resp.data,
                                logMessage: logMessage,
                                completionModelHandler: completionModelHandler)
            case .failure(let error):
                logMessage += "\nfail: \(error.localizedDescription)"
                logMessage += line
                logMessage.logD()
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
//        networkLoggerPlugin()
        if writeCache {
//            writeCachePlugin()
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
                                           logMessage: String = "",
                                           completionModelHandler: CompletionModelClosure?) -> Void {
        
        var logMessage = logMessage
        
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
                    logMessage += "\nfail: data empty"
                    logMessage.logD()
                    callBack(nil, isCache, code)
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                // 请求结果 (尝试解析为 JSON)
                if isCache {
                    logMessage += line
                    logMessage += "\nresponse cache: \n\(json)"
                    logMessage += line
                } else {
                    logMessage += "\nresponse: \n\(json)"
                    logMessage += line
                }
                logMessage.logD()
                
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
                
                logMessage += "\nresponse: JSON error"
                logMessage.logD()
#if Debug
                fatalError("unknow error")
#endif
            }
        default:
            ()
        }
    }
}
