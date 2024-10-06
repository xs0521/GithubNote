//
//  SQLManager+Comment.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import FMDB

extension SQLManager {
    
    func insertComments(comments: [Comment], into tableName: String, database: FMDatabase) {
        let insertSQL = """
        INSERT OR REPLACE INTO \(tableName) (id, url, htmlURL, issueURL, nodeID, createdAt, updatedAt, body)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if database.open() {
            database.beginTransaction()
            comments.forEach { comment in
                do {
                    try database.executeUpdate(insertSQL, values: [
                        comment.id ?? NSNull(),
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
    
    func fetchComments(from tableName: String, where issueURL: String, database: FMDatabase) -> [Comment] {
        var comments = [Comment]()
        let selectSQL = "SELECT * FROM \(tableName) WHERE issueURL = ?;"
        
        if database.open() {
            do {
                let resultSet = try database.executeQuery(selectSQL, values: [issueURL])
                
                while resultSet.next() {
                    let comment = Comment(
                        id: Int(resultSet.longLongInt(forColumn: "id")),
                        url: resultSet.string(forColumn: "url"),
                        htmlUrl: resultSet.string(forColumn: "htmlURL"),
                        issueUrl: resultSet.string(forColumn: "issueURL"),
                        nodeId: resultSet.string(forColumn: "nodeID"),
                        createdAt: resultSet.string(forColumn: "createdAt"),
                        updatedAt: resultSet.string(forColumn: "updatedAt"),
                        body: resultSet.string(forColumn: "body")
                    )
                    comments.append(comment)
                }
                
            } catch {
                print("Failed to fetch comments: \(error.localizedDescription)")
            }
        }
        database.close()
        
        return comments
    }
    
    func updateComment(comment: Comment, in tableName: String, database: FMDatabase) {
        let updateSQL = """
        UPDATE \(tableName) SET url = ?, htmlURL = ?, issueURL = ?, nodeID = ?, createdAt = ?, updatedAt = ?, body = ?
        WHERE id = ?;
        """
        
        if database.open() {
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
                print("Comment updated successfully")
            } catch {
                print("Failed to update comment: \(error.localizedDescription)")
            }
        }
        database.close()
    }
    
    func deleteComment(byId id: Int, from tableName: String, database: FMDatabase) {
        let deleteSQL = "DELETE FROM \(tableName) WHERE id = ?;"
        
        if database.open() {
            do {
                try database.executeUpdate(deleteSQL, values: [id])
                print("Comment deleted successfully")
            } catch {
                print("Failed to delete comment: \(error.localizedDescription)")
            }
        }
        database.close()
    }
}
