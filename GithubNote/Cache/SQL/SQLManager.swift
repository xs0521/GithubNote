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
    
    private lazy var dbURL: URL = {
        
        let bundleID = Bundle.main.bundleIdentifier ?? "github.note"
        var userId = UserManager.shared.user?.id ?? 0
        assert(userId > 0, "userId error")
        
        let fileManager = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                            .userDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        var dirPath = (docsDir as NSString).appendingPathComponent(bundleID)
        
        do {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            "#db# Directory created at: \(dirPath)".logI()
        } catch {
            "#db# Error creating directory: \(error.localizedDescription)".logE()
        }
        
        dirPath = (dirPath as NSString).appendingPathComponent("\(userId)")
        
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
    
    func clear() -> Void {
        if self.db.open() {
            self.db.close()
        }
    }
    
    private func createRepoTable() {
        
        let sql = """
                CREATE TABLE IF NOT EXISTS Repo(
                    id INTEGER PRIMARY KEY,
                    sort INTEGER,
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
                        sort INTEGER,
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
    
    func commentTableName(_ issueID: Int = 0) -> String {
        var id = issueID
        if id <= 0 {
            guard let issue = CacheManager.shared.currentIssue, let issueID = issue.id else {
                assert(false, "issueID error")
                return ""
            }
            id = issueID
        }
        assert(id > 0, "issueID error")
        return "Comment_\(id%10)"
    }
    
    func createCommentTable() -> Void {
        
        let tableName = commentTableName()
        let sql = """
                CREATE TABLE IF NOT EXISTS \(tableName)(
                    id INTEGER PRIMARY KEY,
                    sort INTEGER,
                    url TEXT,
                    htmlURL TEXT,
                    issueURL TEXT,
                    nodeID TEXT,
                    createdAt TEXT,
                    updatedAt TEXT,
                    body TEXT,
                    cache TEXT,
                    cacheUpdate INTEGER
                );
                """
        
        createTable(sql, tableName: tableName)
    }
    
    func imagesTableName() -> String {
        let id = CacheManager.shared.currentRepo?.id ?? 0
        let name = CacheManager.shared.currentRepo?.name ?? ""
        assert(id > 0, "id error")
        return "images_\(name)_\(id)"
    }
    
    func createImagesTable() -> Void {
        
        let tableName = imagesTableName()
        let sql = """
                CREATE TABLE IF NOT EXISTS \(tableName)(
                    idx INTEGER PRIMARY KEY AUTOINCREMENT,
                    url TEXT,
                    uuid TEXT,
                    name TEXT,
                    path TEXT,
                    sha TEXT,
                    size INTEGER,
                    htmlURL TEXT,
                    gitURL TEXT,
                    downloadURL TEXT,
                    type TEXT
                );
                """
        
        createTable(sql, tableName: tableName)
    }
    
    func getMaxIndex(_ tableName: String, from database: FMDatabase) -> Int {
        var maxIndex: Int = 0
        let querySQL = "SELECT MAX(sort) as maxIndex FROM \(tableName);"
        
        if let resultSet = try? database.executeQuery(querySQL, values: nil) {
            if resultSet.next() {
                maxIndex = Int(resultSet.int(forColumn: "maxIndex"))
            }
        }
        
        return maxIndex
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

extension SQLManager {
    
    func insertItems<T: SQLModelable>(items: [T], database: FMDatabase) {
        
        guard let item = items.first else {
            "No repositories to insert.".logI()
            return
        }
        
        var index = item.maxIndex(database)

        if database.open() {
            do {
                database.beginTransaction() // 开始事务
                for item in items {
                    index += 1
                    try database.executeUpdate(item.insertSql, values: item.insertValues(index))
                }
                database.commit() // 提交事务
                "Batch insert or update successful".logI()
            } catch {
                database.rollback() // 回滚事务
                "Failed to insert or update: \(error.localizedDescription)".logE()
            }
        } else {
            "Failed to open database".logE()
        }
    }
    
    func fetchItems<T: SQLModelable>(database: FMDatabase, where value: String? = nil) -> [T] {
        
        let selectSQL = T.fetchSql
        var items = [T]()
        
        do {
            let results = try database.executeQuery(selectSQL, values: value != nil ? [value as Any] : nil)
            while results.next() {
                let item = T.item(results)
                items.append(item)
            }
            
        } catch {
            "Failed to fetch repos: \(error.localizedDescription)".logE()
        }
        
        return items
    }
    
    func updateItems<T: SQLModelable>(items: [T], database: FMDatabase) {
        
        guard let item = items.first else {
            "No items to update.".logI()
            return
        }
        
        let updateSQL = item.updateSql
        
        if database.open() {
            items.forEach { item in
                do {
                    try database.executeUpdate(updateSQL, values: item.updateValues())
                } catch {
                    "Failed to update comment: \(error.localizedDescription)".logE()
                }
            }
            "Comment updated successfully".logI()
        }
        database.close()
    }
    
    func deleteItems(in tableName: String,  byId ids: [Int], database: FMDatabase) {
        
        // 通过类型T访问 static 的 tableName
        let deleteSQL = "DELETE FROM \(tableName) WHERE id = ?;"
        
        if database.open() {
            ids.forEach { id in
                do {
                    try database.executeUpdate(deleteSQL, values: [id])
                } catch {
                    "Failed to delete item: \(error.localizedDescription)".logE()
                }
            }
            "Items deleted successfully".logI()
        } else {
            "Failed to open database".logE()
        }
        database.close()
    }
}
