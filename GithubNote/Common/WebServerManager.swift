//
//  WebServerManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import GCDWebServer

class WebServerManager: Setupable {
    static let shared = WebServerManager()
    
    private var webServer: GCDWebServer?
    
    init() {
        let webServer = GCDWebUploader(uploadDirectory: NSHomeDirectory())
        webServer.start()
        self.webServer = webServer
        print("Visit \(webServer.serverURL?.absoluteString ?? "") in your web browser")
    }
    
    static func setup() {
        
        let _ = WebServerManager.shared
    }
}
