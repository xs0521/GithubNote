//
//  TimeManager.swift
//  GithubNote
//
//  Created by luoshuai on 2024/10/16.
//

import Foundation

class TimeManager {
    
    lazy var titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    lazy var isoFormatter: ISO8601DateFormatter = {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter
    }()
    
    static let shared = TimeManager()
}
