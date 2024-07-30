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
}
