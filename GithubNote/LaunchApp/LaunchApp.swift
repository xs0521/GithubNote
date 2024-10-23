//
//  LaunchApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import Foundation

private let SETUPLIST: [Setupable.Type] = [LogManager.self,
                                           WebServerManager.self]

private let SETUPLISTLOGIN: [Setupable.Type] = [SDWebImageDownloaderSetup.self,
                                                CacheManager.self]

class LaunchApp {
    static let shared = LaunchApp()
    init() {
        SETUPLIST.forEach({$0.setup()})
        if UserManager.shared.isLogin() {
            loginSetup()
        }
    }
    
    func loginSetup() -> Void {
        SETUPLISTLOGIN.forEach({$0.setup()})
    }
}
