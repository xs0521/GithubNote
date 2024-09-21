//
//  LaunchApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import Foundation

class LaunchApp {
    static let shared = LaunchApp()
    init() {
        LogManager.setup()
    }
}
