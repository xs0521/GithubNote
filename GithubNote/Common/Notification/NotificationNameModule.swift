//
//  NotificationNameModule.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/30.
//

import Foundation

extension Notification.Name {
    static let appendImagesNotification = Notification.Name(rawValue: "sync.append.image")
    static let syncNetImagesNotification = Notification.Name(rawValue: "sync.net.images")
    static let logoutNotification = Notification.Name(rawValue: "app.github.logout")
    static let logoutForceNotification = Notification.Name(rawValue: "app.github.logout.force")
    static let logNotification = Notification.Name(rawValue: "app.github.log")
}
