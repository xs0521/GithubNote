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
        return "### note \(time)"
    }
}


extension AppConst {
    static let issueItemHeight: CGFloat = 30
    static let issueMaxWidth: CGFloat = 200
    static let issueMinWidth: CGFloat = 50
}

extension AppConst {
    static let commentItemHeight: CGFloat = 30
    static let commentMaxWidth: CGFloat = 200
    static let commentMinWidth: CGFloat = 50
}

extension AppConst {
    static let editMinWidth: CGFloat = 800
    static let editItemMinWidth: CGFloat = 50
}

extension AppConst {
    static let minWidth: CGFloat = issueMinWidth + commentMinWidth + editMinWidth
    static let minHeight: CGFloat = 600
    
    static let defaultWidth: CGFloat = 1200
    static let defaultHeight: CGFloat = 800
}
