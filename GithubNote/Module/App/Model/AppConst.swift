//
//  AppConst.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation

struct AppConst {}

extension AppConst {
    
    static var markdown: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd HH:mm:ss"
        let time = dateformatter.string(from: Date())
        return "### Note \(time)"
    }
    
    static var issueMarkdown: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd HH:mm:ss"
        let time = dateformatter.string(from: Date())
        return "NoteBook \(time)"
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
    
    static let downloadIcon = "arrow.down.square.fill"
    static let plusIcon = "plus.circle.fill"
    static let photoIcon = "photo.fill"
    static let closeIcon = "xmark.circle.fill"
    static let pencilIcon = "square.and.pencil.circle.fill"
}


extension AppConst {
    
    static let scheme = "githubnote"
}
