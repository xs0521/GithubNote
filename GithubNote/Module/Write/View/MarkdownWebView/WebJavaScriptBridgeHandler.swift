//
//  WebJavaScriptBridgeHandler.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/9.
//

import Foundation

enum WebJavaScriptBridgeActionType: String {
    case update = "update"
}

struct WebJavaScriptBridgeHandler {
    
    static func parse(_ value: Any) -> Void {
        
        if let dictionary = value as? Dictionary<String, Any> {
            handle(dict: dictionary)
            return
        }
        
        if let content = value as? String {
            guard let jsonData = content.data(using: .utf8) else {
                "JSON error".logE()
                return
            }
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    handle(dict: dictionary)
                }
            } catch {
                "JSON error: \(error)".logE()
            }
        }
        
    }
    
    static private func handle(dict: Dictionary<String, Any>) -> Void {
        
        guard let value = dict["action"] as? String, let action = WebJavaScriptBridgeActionType(rawValue: value) else { return }
        
        switch action {
        case .update:
            guard let content = dict["content"] as? String else { return }
            writeStore.editMarkdownString = content
            "#web# content \(content)".logI()
        }
    }
}
