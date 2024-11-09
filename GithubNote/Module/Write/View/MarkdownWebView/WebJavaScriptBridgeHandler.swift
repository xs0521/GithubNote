//
//  WebJavaScriptBridgeHandler.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/9.
//

import Foundation

struct WebJavaScriptBridgeHandler {
    
    static func parse(_ value: Any) -> Void {
        if let content = value as? String {
            "#MD# 接收到编辑器内容: \(content)".logI()
//            if writeStore.markdownString != content {
//                writeStore.markdownString = content
//            }
        }
    }
}
