//
//  LaunchApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import Foundation
import AppKit

private let SETUPLIST: [Setupable.Type] = [LogManager.self,
                                           WebServerManager.self,
                                           CustomURLSchemeHandler.self]

private let SETUPLISTLOGIN: [Setupable.Type] = [SDWebImageDownloaderSetup.self,
                                                CacheManager.self,
                                                VersionUpdateManagerSetup.self]

class LaunchApp {
    static let shared = LaunchApp()
    var isHoverArea = false
    
    init() {
        SETUPLIST.forEach({$0.setup()})
        if UserManager.shared.isLogin() {
            loginSetup()
        }
        
        //开启对键盘的监听
        configKeyboard()
        configMouse()
    }
    
    func loginSetup() -> Void {
        SETUPLISTLOGIN.forEach({$0.setup()})
    }
}
