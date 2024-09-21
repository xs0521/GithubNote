//
//  CustomLogFormatter.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import CocoaLumberjack

private class CustomLogFormatter: NSObject, DDLogFormatter {
    
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
        
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        // 返回自定义格式的日志字符串
        return "\(timestamp): [\(flag)] \(fileName)[\(line)] - \(logMessage.message)"
    }
}

class CustomFileLogFormatter: DDDispatchQueueLogFormatter {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = .current
        return dateFormatter
    }()
    
    override func format(message logMessage: DDLogMessage) -> String? {
        
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        // 自定义日志格式
        let logLevel: String
        switch logMessage.level {
        case .error:
            logLevel = "E"
        case .warning:
            logLevel = "W"
        case .info:
            logLevel = "I"
        case .debug:
            logLevel = "D"
        case .verbose:
            logLevel = "V"
        default:
            logLevel = "L"
        }
        
        return "\(timestamp) [\(logLevel)] \(logMessage.message)\n"
    }
}

struct LogManager {
    
    static func setup() {
        
        DDLog.add(DDTTYLogger.sharedInstance!)
        DDTTYLogger.sharedInstance?.logFormatter = CustomLogFormatter()
        
        let fileLogger: DDFileLogger = DDFileLogger()
        let customFormatter = CustomLogFormatter()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.logFormatter = customFormatter
        DDLog.add(fileLogger)
        
        DDLogInfo("#log# CocoaLumberjack has been set up.")
    }
    
    static func exportLogs(_ completion: @escaping CommonTCallBack<Bool>) {
        
        guard let fileLogger = DDLog.allLoggers.first(where: { $0 is DDFileLogger }) as? DDFileLogger else {
            "#log# No file logger found.".logE()
            return
        }
        
        let logFileManager = fileLogger.logFileManager
        
        // 获取日志文件路径
        let logFiles = logFileManager.sortedLogFileInfos
        // 创建 NSOpenPanel 选择导出目录
        let dialog = NSOpenPanel()
        dialog.title = "#log# Choose a directory to save logs"
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false
        
        dialog.begin { result in
            
            guard result == .OK, let url = dialog.url else {
                "#log# User canceled the dialog.".logW()
                return
            }
            
            // 在目标目录中创建一个新文件夹
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMdd_HHmmss"
            dateFormatter.timeZone = .current
            let folderName = "logs-\(dateFormatter.string(from: Date()))"
            
            let exportFolderURL = url.appendingPathComponent(folderName)
            
            do {
                try FileManager.default.createDirectory(at: exportFolderURL, withIntermediateDirectories: true, attributes: nil)
                "#log# Created folder: \(exportFolderURL.path)".logI()
                
                // 将日志文件复制到新文件夹中
                for logFile in logFiles {
                    let sourceURL = logFile.filePath
                    let destinationURL = exportFolderURL.appendingPathComponent(logFile.fileName)
                    
                    try FileManager.default.copyItem(atPath: sourceURL, toPath: destinationURL.path)
                    "#log# Exported: \(logFile.fileName) to \(exportFolderURL.path)".logI()
                }
                
                DispatchQueue.main.async {
                    completion(true)
                }
                
            } catch {
                "#log# Error during file operation: \(error.localizedDescription)".logE()
            }
            
        }
    }
}
