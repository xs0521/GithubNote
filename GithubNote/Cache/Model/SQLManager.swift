//
//  SQLManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import FMDB

private let dbName = "note.db"

class SQLManager {
    
    static let shared = SQLManager()
    
    private lazy var dbURL: URL = {
        let fileManager = FileManager.default
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                            .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        var dirPath = (docsDir as NSString).appendingPathComponent("github.note")
        
        do {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            "#db# Directory created at: \(dirPath)".logI()
        } catch {
            "#db# Error creating directory: \(error.localizedDescription)".logE()
        }
        
        ///TODO
        let id = "10003"
        dirPath = (dirPath as NSString).appendingPathComponent(id)
        
        do {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            "#db# Directory created at: \(dirPath)".logI()
        } catch {
            "#db# Error creating directory: \(error.localizedDescription)".logE()
        }
        
        dirPath = (dirPath as NSString).appendingPathComponent(dbName)
        let url = URL(filePath: dirPath)
        return url
    }()
    
    
    lazy var db: FMDatabase = {
        let database = FMDatabase(url: dbURL)
        return database
    }()
    
    lazy var dbQueue: FMDatabaseQueue? = {
        // 根据路径返回数据库
        let databaseQueue = FMDatabaseQueue(url: dbURL)
        return databaseQueue
    }()
    
    init() {
        createRepoTable()
    }
    
    private func createRepoTable() {
        
        let sql = """
                CREATE TABLE IF NOT EXISTS Repo(
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    fullName TEXT,
                    url TEXT,
                    createdAt TEXT,
                    updatedAt TEXT,
                    pushedAt TEXT,
                    private INTEGER
                );
                """
        
        if self.db.open() {
            let success = db.executeStatements(sql)
            "#db# TABLE created \(success)".logW()
        }
        self.db.close()
    }
    
    func issueTableName() -> String {
        guard let repo = CacheManager.shared.currentRepo, let repoID = repo.id else {
            assert(false, "repo error")
            return ""
        }
        assert(repoID > 0, "repoID error")
        return "Issue_\(repoID%10)"
    }
    
    func createIssueTable() -> Void {
        let tableName = issueTableName()
        let sql = """
                    CREATE TABLE IF NOT EXISTS \(tableName)(
                        id INTEGER PRIMARY KEY,
                        url TEXT,
                        repositoryUrl TEXT,
                        number INTEGER,
                        title TEXT,
                        body TEXT,
                        state INTEGER
                    );
                    """
        
        createTable(sql, tableName: tableName)
    }
    
    func commentTableName() -> String {
        guard let issue = CacheManager.shared.currentIssue, let issueID = issue.id else {
            assert(false, "issueID error")
            return ""
        }
        assert(issueID > 0, "issueID error")
        return "Comment_\(issueID%10)"
    }
    
    func createCommentTable() -> Void {
        
        let tableName = commentTableName()
        let sql = """
                CREATE TABLE IF NOT EXISTS \(tableName)(
                    id INTEGER PRIMARY KEY,
                    url TEXT,
                    htmlURL TEXT,
                    issueURL TEXT,
                    nodeID TEXT,
                    createdAt TEXT,
                    updatedAt TEXT,
                    body TEXT
                );
                """
        
        createTable(sql, tableName: tableName)
    }
    
    private func createTable(_ sql: String, tableName: String) -> Void {
        if !isTableExist(tableName: tableName) {
            if self.db.open() {
                let success = db.executeStatements(sql)
                "#db# TABLE created \(tableName) \(success)".logW()
            }
            self.db.close()
        } else {
            "#db# Table \(tableName) already exists.".logW()
        }
    }
    
    private func isTableExist(tableName: String) -> Bool {
        var tableExists = false
        
        if self.db.open() {
            let checkSQL = "SELECT count(*) as count FROM sqlite_master WHERE type='table' AND name=?;"
            
            do {
                let resultSet = try db.executeQuery(checkSQL, values: [tableName])
                if resultSet.next() {
                    let count = resultSet.int(forColumn: "count")
                    tableExists = (count > 0)
                }
            } catch {
                "Error checking table existence: \(error.localizedDescription)".logE()
            }
            
            self.db.close()
        }
        
        return tableExists
    }
}
