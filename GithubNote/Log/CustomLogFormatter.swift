//
//  CustomLogFormatter.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {
    
    private let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        // 设置日期格式
        dateFormatter.dateFormat = "yyyyMMdd HH:mm:ss.SSS z"
        // 设置时区，例如设置为东八区（中国标准时间）
        dateFormatter.timeZone = .current
        super.init()
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        var flag = ""
        switch logMessage.flag {
        case .debug:
            flag = "D"
        case .error:
            flag = "E"
        case .warning:
            flag = "W"
        case .info:
            flag = "I"
        case .verbose:
            flag = "V"
        default:
            flag = ""
        }
        let fileName = logMessage.fileName
        let line = logMessage.line
        let function = logMessage.function
        
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        // 返回自定义格式的日志字符串
        return "\(timestamp): [\(flag)] \(fileName)[\(line)] \(function ?? "") - \(logMessage.message)"
    }
}
