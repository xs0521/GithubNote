//
//  NotificationNameModule.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/30.
//

import Foundation

extension Notification.Name {
    static let syncLocalImagesNotification = Notification.Name(rawValue: "sync.local.images")
    static let syncNetImagesNotification = Notification.Name(rawValue: "sync.net.images")
}
