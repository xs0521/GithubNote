//
//  AppConst.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation

struct AppConst {}

extension AppConst {
    
    static var noteRepo: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMdd-HHmmss"
        let time = dateformatter.string(from: Date())
        return "GithubNote-\(time)"
    }
    
    static var markdown: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd HH:mm:ss"
        let time = dateformatter.string(from: Date())
        return "### \("note".language()) \(time)"
    }
    
    static var issueMarkdown: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd HH:mm:ss"
        let time = dateformatter.string(from: Date())
        return "\("notebook".language()) \(time)"
    }
    
    static var issueBodyMarkdown: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd HH:mm:ss"
        let time = dateformatter.string(from: Date())
        return "Body \(time)"
    }
}

extension AppConst {
    
    static let defaultWidth: CGFloat = 1200
    static let defaultHeight: CGFloat = 800
    static let sideItemHeight: CGFloat = 20
}

extension AppConst {
    
    static let settingWindowName = "app.window.group.setting"
}

extension AppConst {
    
    static let downloadIcon = "arrow.down.to.line.compact"
    static let plusIcon = "plus"
    static let photoIcon = "photo.fill"
    static let closeIcon = "xmark"
}


extension AppConst {
    
    static let scheme = "githubnote"
}
