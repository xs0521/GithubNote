//
//  WebServerManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
#if canImport(GCDWebServer)
import GCDWebServer
#endif

class WebServerManager: Setupable {
    static let shared = WebServerManager()
    
#if canImport(GCDWebServer)
    private var webServer: GCDWebServer?
    
    init() {
        let webServer = GCDWebUploader(uploadDirectory: NSHomeDirectory())
        webServer.start()
        self.webServer = webServer
        print("Visit \(webServer.serverURL?.absoluteString ?? "") in your web browser")
    }
#endif
    
    static func setup() {
        
        let _ = WebServerManager.shared
    }
}
