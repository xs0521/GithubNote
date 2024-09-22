//
//  LaunchApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import Foundation
import WebKit
import SDWebImage

class LaunchApp {
    static let shared = LaunchApp()
    init() {
        LogManager.setup()
        WKWebView.swizzleHandlesURLScheme
        if !Account.accessToken.isEmpty {
            SDWebImageDownloader.shared.setValue("Bearer \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
}
