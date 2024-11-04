//
//  CustomURLSchemeHandler.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import WebKit
import SDWebImage
import UniformTypeIdentifiers

class CustomURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
        guard var url = urlSchemeTask.request.url?.absoluteString else { return }
        
        url = CustomURLSchemeHandler.handleImageText(url, true)
        
        guard let Url = URL(string: url) else {
            "#web# url error ".logE()
            return
        }
        
        func callBack(_ data: Data) -> Void {
            // 创建 HTTP 响应
            let backResponse = HTTPURLResponse(url: Url,
                                               statusCode: 200,
                                               httpVersion: "HTTP/1.1",
                                               headerFields: self.getResponseHeaders(url))!
            
            
            
            // 将响应和数据返回给 WebView
            urlSchemeTask.didReceive(backResponse)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
        
        if url.isImage() {
            "#web# img is image \(url)".logI()
            let key = url
            
            let cache = SDWebImageManager.defaultImageCache as! SDImageCache
            
            if let data = cache.diskImageData(forKey: key) {
                "#web# img load cache \(url)".logI()
                callBack(data)
                return
            }
            
            SDWebImageDownloader.shared.downloadImage(with: Url) { _, data, error, finish in
                if let data = data, error == nil {
                    cache.storeImageData(toDisk: data, forKey: key)
                    callBack(data)
                    "#web# img sccess \(url)".logI()
                } else {
                    "#web# img fail: \(error?.localizedDescription ?? "")".logE()
                }
            }
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlSchemeTask.request) { data, response, error in
            if let data = data, let _ = response {
                callBack(data)
                "#web# file \(url)".logI()
            } else if let error = error {
                // 如果出错，通知 WebView
                urlSchemeTask.didFailWithError(error)
                "#web# file fail \(error.localizedDescription)".logE()
            }
        }
        
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // 停止任务的逻辑 (如果需要)
    }
    
    // 获取响应头
    func getResponseHeaders(_ url: String) -> [String: String] {
        return [
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Content-Type": fileMIMETypeWithCAPI(at: url)
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
