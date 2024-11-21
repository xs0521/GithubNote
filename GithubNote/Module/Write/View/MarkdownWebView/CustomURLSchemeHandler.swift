//
//  CustomURLSchemeHandler.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import WebKit
import SDWebImage
import UniformTypeIdentifiers
import WebKit
import ObjectiveC.runtime

class CustomURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    private var tokenMap: [String : SDWebImageDownloadToken] = [:]
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
        guard let url = urlSchemeTask.request.url?.absoluteString else { return }
        
        guard let _ = URL(string: url) else {
            "#web# url error ".logE()
            callBack(Data(), nil)
            return
        }
        
        let cache = SDWebImageManager.defaultImageCache as! SDImageCache
        
        if let data = cache.diskImageData(forKey: url) {
            "#web# img load cache \(url)".logI()
            callBack(data)
            return
        }
        
        let token = SDWebImageDownloader.shared.downloadImage(with: URL(string: url)) { [weak self] _, data, error, finish in
            guard let self = self else { return }
            
            let currentToken = self.tokenMap[url]
            guard let response = currentToken?.response else { return }
            
            if let data = data, error == nil {
                cache.storeImageData(toDisk: data, forKey: url)
                callBack(data, response)
                "#web# img sccess \(url)".logI()
            } else {
                "#web# img fail: \(error?.localizedDescription ?? "")".logE()
                callBack(Data(), response)
            }
        }
        tokenMap[url] = token
        
        func callBack(_ data: Data, _ response: URLResponse? = nil) -> Void {
            
            let headerFields: [String: String] = [
                "Content-Type": response?.mimeType ?? data.mimeTypeMagicBytes(),
                "Content-Length": "\(data.count)"
            ]
            
            let backResponse = HTTPURLResponse(url: URL(string: url)!,
                                               statusCode: 200,
                                               httpVersion: "HTTP/1.1",
                                               headerFields: headerFields)!
            
            
            
            
            urlSchemeTask.didReceive(backResponse)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // 停止任务的逻辑 (如果需要)
    }
    
    // 获取响应头
    func getResponseHeaders(_ data: Data) -> [String: String] {
        return [
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Content-Type": data.mimeTypeMagicBytes()
        ]
    }
    
    static func handleImageText(_ text: String, _  recover: Bool = false) -> String {
        let github = "https://raw.githubusercontent.com"
        let replace = "\(AppConst.scheme)://raw.githubusercontent.com"
        if recover {
            return text.replacingOccurrences(of: replace, with: github)
        }
        return text.replacingOccurrences(of: github, with: replace)
    }
    
}

func fileMIMETypeWithCAPI(at filePath: String) -> String {
    // 获取文件的扩展名
    let fileExtension = (filePath as NSString).pathExtension
    
#if !MOBILE
    // 根据扩展名获取 UTI
    if let utType = UTType(filenameExtension: fileExtension) {
        // 根据 UTI 获取 MIME 类型
        if let mimeType = utType.preferredMIMEType {
            return mimeType
        }
    }
#endif
    
    // 默认返回值
    return "application/octet-stream"
}

extension CustomURLSchemeHandler: Setupable {
    
    static func setup() {
        WKWebView.swizzleHandlesURLScheme
    }
}

extension WKWebView {
    
    static let swizzleHandlesURLScheme: Void = {
        let originalSelector = #selector(handlesURLScheme(_:))
        let swizzledSelector = #selector(swizzledHandlesURLScheme(_:))
        
        if let originalMethod = class_getClassMethod(WKWebView.self, originalSelector),
           let swizzledMethod = class_getClassMethod(WKWebView.self, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    @objc class func swizzledHandlesURLScheme(_ urlScheme: String) -> Bool {
        if urlScheme == "http" || urlScheme == "https" {
            return false  // 这里返回 NO，避免系统处理，使用自定义 handler 处理
        } else {
            return swizzledHandlesURLScheme(urlScheme)  // 调用原始实现
        }
    }
}
