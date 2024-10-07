//
//  SQLManager+Issue.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import FMDB

extension SQLManager {
    
    func insertIssue(issues: [Issue], into tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        var preIndex = getMaxIndex(tableName, from: database)
        
        let insertSQL = """
        INSERT OR REPLACE INTO \(tableName) (id, sort, url, repositoryUrl, number, title, body, state)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if database.open() {
            database.beginTransaction()
            issues.forEach { issue in
                do {
                    preIndex += 1
                    try database.executeUpdate(insertSQL, values: [
                        issue.id ?? NSNull(),
                        preIndex,
                        issue.url ?? NSNull(),
                        issue.repositoryUrl ?? NSNull(),
                        issue.number ?? NSNull(),
                        issue.title ?? NSNull(),
                        issue.body ?? NSNull(),
                        issue.state?.rawValue ?? NSNull()
                    ])
                } catch {
                    database.rollback()
                    "Failed to insert issue: \(error.localizedDescription)".logE()
                }
            }
            database.commit()
            "Issue inserted into \(tableName) successfully".logI()
        }
        database.close()
    }
    
    func fetchIssues(from tableName: String?, where repositoryUrl: String, database: FMDatabase) -> [Issue] {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return []
        }
        
        var issues = [Issue]()
        let selectSQL = "SELECT * FROM \(tableName)  WHERE repositoryUrl = ? ORDER BY sort;"
        
        if database.open() {
            do {
                let resultSet = try database.executeQuery(selectSQL, values: [repositoryUrl])
                
                while resultSet.next() {
                    let issue = Issue(
                        id: Int(resultSet.longLongInt(forColumn: "id")),
                        url: resultSet.string(forColumn: "url"),
                        repositoryUrl: resultSet.string(forColumn: "repositoryUrl"),
                        number: Int(resultSet.int(forColumn: "number")),
                        title: resultSet.string(forColumn: "title"),
                        body: resultSet.string(forColumn: "body"),
                        state: IssueState(rawValue: resultSet.string(forColumn: "state") ?? "open")
                    )
                    issues.append(issue)
                }
                
            } catch {
                "Failed to fetch issues: \(error.localizedDescription)".logE()
            }
        }
        database.close()
        
        return issues
    }
    
    func updateIssue(issue: Issue, in tableName: String, database: FMDatabase) {
        let updateSQL = """
        UPDATE \(tableName) SET url = ?, repositoryUrl = ?, number = ?, title = ?, body = ?, state = ?
        WHERE id = ?;
        """
        
        if database.open() {
            do {
                try database.executeUpdate(updateSQL, values: [
                    issue.url ?? NSNull(),
                    issue.repositoryUrl ?? NSNull(),
                    issue.number ?? NSNull(),
                    issue.title ?? NSNull(),
                    issue.body ?? NSNull(),
                    issue.state?.rawValue ?? NSNull(),
                    issue.id ?? NSNull()
                ])
                "Issue updated successfully".logI()
            } catch {
                "Failed to update issue: \(error.localizedDescription)".logE()
            }
        }
        database.close()
    }
    
    func deleteIssue(byId id: Int, from tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let deleteSQL = "DELETE FROM \(tableName) WHERE id = ?;"
        
        if database.open() {
            do {
                try database.executeUpdate(deleteSQL, values: [id])
                "Issue deleted successfully".logI()
            } catch {
                "Failed to delete issue: \(error.localizedDescription)".logE()
            }
        }
        database.close()
    }
}
