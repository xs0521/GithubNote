//
//  SQLManager+Comment.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import FMDB

extension SQLManager {
    
    func insertComments(comments: [Comment], into tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        var preIndex = getMaxIndex(tableName, from: database)
        
        let insertSQL = """
        INSERT OR REPLACE INTO \(tableName) (id, sort, url, htmlURL, issueURL, nodeID, createdAt, updatedAt, body)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if database.open() {
            database.beginTransaction()
            comments.forEach { comment in
                do {
                    preIndex += 1
                    try database.executeUpdate(insertSQL, values: [
                        comment.id ?? NSNull(),
                        preIndex,
                        comment.url ?? NSNull(),
                        comment.htmlUrl ?? NSNull(),
                        comment.issueUrl ?? NSNull(),
                        comment.nodeId ?? NSNull(),
                        comment.createdAt ?? NSNull(),
                        comment.updatedAt ?? NSNull(),
                        comment.body ?? NSNull()
                    ])
                } catch {
                    "Failed to insert comment: \(error.localizedDescription)".logE()
                }
            }
            database.commit()
            "Comment inserted into \(tableName) successfully".logI()
        }
        database.close()
    }
    
    func fetchComment(from tableName: String?, where id: NSInteger, database: FMDatabase) -> Comment? {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return nil
        }
        
        let selectSQL = "SELECT * FROM \(tableName) WHERE id = ? ORDER BY sort;"
        var comment: Comment?
        
        if database.open() {
            do {
                let resultSet = try database.executeQuery(selectSQL, values: [id])
                
                while resultSet.next() {
                    var item = Comment(
                        id: Int(resultSet.longLongInt(forColumn: "id")),
                        url: resultSet.string(forColumn: "url"),
                        htmlUrl: resultSet.string(forColumn: "htmlURL"),
                        issueUrl: resultSet.string(forColumn: "issueURL"),
                        nodeId: resultSet.string(forColumn: "nodeID"),
                        createdAt: resultSet.string(forColumn: "createdAt"),
                        updatedAt: resultSet.string(forColumn: "updatedAt"),
                        body: resultSet.string(forColumn: "body"),
                        cache: resultSet.string(forColumn: "cache"),
                        cacheUpdate: Int(resultSet.longLongInt(forColumn: "cacheUpdate"))
                    )
                    item.defultModel()
                    comment = item
                }
                
            } catch {
                "Failed to fetch comments: \(error.localizedDescription)".logE()
            }
        }
        database.close()
        return comment
    }
    
    func fetchComments(from tableName: String?, where issueURL: String, database: FMDatabase) -> [Comment] {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return []
        }
        
        var comments = [Comment]()
        let selectSQL = "SELECT * FROM \(tableName) WHERE issueURL = ? ORDER BY sort;"
        
        if database.open() {
            do {
                let resultSet = try database.executeQuery(selectSQL, values: [issueURL])
                
                while resultSet.next() {
                    var comment = Comment(
                        id: Int(resultSet.longLongInt(forColumn: "id")),
                        url: resultSet.string(forColumn: "url"),
                        htmlUrl: resultSet.string(forColumn: "htmlURL"),
                        issueUrl: resultSet.string(forColumn: "issueURL"),
                        nodeId: resultSet.string(forColumn: "nodeID"),
                        createdAt: resultSet.string(forColumn: "createdAt"),
                        updatedAt: resultSet.string(forColumn: "updatedAt"),
                        body: resultSet.string(forColumn: "body"),
                        cache: resultSet.string(forColumn: "cache"),
                        cacheUpdate: Int(resultSet.longLongInt(forColumn: "cacheUpdate"))
                    )
                    comment.defultModel()
                    comments.append(comment)
                }
                
            } catch {
                "Failed to fetch comments: \(error.localizedDescription)".logE()
            }
        }
        database.close()
        
        return comments
    }
    
    func updateComments(comments: [Comment], in tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let updateSQL = """
        UPDATE \(tableName) SET url = ?, htmlURL = ?, issueURL = ?, nodeID = ?, createdAt = ?, updatedAt = ?, body = ?
        WHERE id = ?;
        """
        
        if database.open() {
            comments.forEach { comment in
                do {
                    try database.executeUpdate(updateSQL, values: [
                        comment.url ?? NSNull(),
                        comment.htmlUrl ?? NSNull(),
                        comment.issueUrl ?? NSNull(),
                        comment.nodeId ?? NSNull(),
                        comment.createdAt ?? NSNull(),
                        comment.updatedAt ?? NSNull(),
                        comment.body ?? NSNull(),
                        comment.id ?? NSNull()
                    ])
                } catch {
                    "Failed to update comment: \(error.localizedDescription)".logE()
                }
            }
            "Comment updated successfully".logI()
        }
        database.close()
    }
    
    func updateCommentCache(comment: Comment, in tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let updateSQL = """
        UPDATE \(tableName) SET cache = ?, cacheUpdate = ? WHERE id = ?;
        """
        
        if database.open() {
            do {
                try database.executeUpdate(updateSQL, values: [
                    comment.cache ?? NSNull(),
                    comment.cacheUpdate ?? NSNull(),
                    comment.id ?? NSNull()
                ])
            } catch {
                "Failed to update cache: \(error.localizedDescription)".logE()
            }
            "Comment cache updated successfully".logI()
        }
        database.close()
    }
    
    func deleteComment(byId ids: [Int], from tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let deleteSQL = "DELETE FROM \(tableName) WHERE id = ?;"
        
        if database.open() {
            ids.forEach { id in
                do {
                    try database.executeUpdate(deleteSQL, values: [id])
                } catch {
                    "Failed to delete comment: \(error.localizedDescription)".logE()
                }
            }
            "Comment deleted successfully".logI()
        }
        database.close()
    }
    
    func deleteComment(byIssueUrl url: String, from tableName: String, database: FMDatabase) {
        let deleteSQL = "DELETE FROM \(tableName) WHERE issueURL = ?;"
        
        if database.open() {
            do {
                try database.executeUpdate(deleteSQL, values: [url])
                "Comment deleted successfully".logI()
            } catch {
                "Failed to delete comment: \(error.localizedDescription)".logE()
            }
        }
        database.close()
    }
}
