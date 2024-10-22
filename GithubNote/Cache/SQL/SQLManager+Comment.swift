//
//  SQLManager+Comment.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import FMDB

extension SQLManager {
    
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
