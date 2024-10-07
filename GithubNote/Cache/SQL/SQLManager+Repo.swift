//
//  SQLManager+Repo.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/6.
//

import Foundation
import FMDB

extension SQLManager {
    
    func insertRepos(repos: [RepoModel], database: FMDatabase) {
        let insertOrUpdateSQL = """
        INSERT OR REPLACE INTO Repo (id, name, fullName, url, createdAt, updatedAt, pushedAt, private)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        // 开始事务
        if database.open() {
            do {
                database.beginTransaction() // 开始事务
                
                for repo in repos {
                    try database.executeUpdate(insertOrUpdateSQL, values: [
                        repo.id ?? NSNull(),
                        repo.name ?? NSNull(),
                        repo.fullName ?? NSNull(),
                        repo.url ?? NSNull(),
                        repo.createdAt ?? NSNull(),
                        repo.updatedAt ?? NSNull(),
                        repo.pushedAt ?? NSNull(),
                        repo.private?.intValue ?? NSNull()
                    ])
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
    
    func updateRepo(repo: RepoModel, database: FMDatabase) {
        let updateSQL = """
        UPDATE Repo
        SET
            name = ?,
            fullName = ?,
            url = ?,
            createdAt = ?,
            updatedAt = ?,
            pushedAt = ?,
            repoPrivate = ?
        WHERE id = ?;
        """
        
        do {
            try database.executeUpdate(updateSQL, values: [
                repo.name ?? NSNull(),
                repo.fullName ?? NSNull(),
                repo.url ?? NSNull(),
                repo.createdAt ?? NSNull(),
                repo.updatedAt ?? NSNull(),
                repo.pushedAt ?? NSNull(),
                repo.private ?? NSNull(),
                repo.id ?? NSNull()  // 使用 id 作为查询条件
            ])
            "Update successful".logI()
        } catch {
            "Failed to update repo: \(error.localizedDescription)".logE()
        }
    }
    
    func fetchRepos(database: FMDatabase) -> [RepoModel] {
        var repos = [RepoModel]()
        let selectSQL = "SELECT * FROM Repo ORDER BY createdAt;"
        
        do {
            let results = try database.executeQuery(selectSQL, values: nil)
            
            while results.next() {
                let repo = RepoModel(
                    id: Int(results.longLongInt(forColumn: "id")),
                    name: results.string(forColumn: "name"),
                    fullName: results.string(forColumn: "fullName"),
                    url: results.string(forColumn: "url"), 
                    createdAt: results.string(forColumn: "createdAt"),
                    updatedAt: results.string(forColumn: "updatedAt"),
                    pushedAt: results.string(forColumn: "pushedAt"),
                    private: results.bool(forColumn: "private")
                )
                repos.append(repo)
            }
            
        } catch {
            "Failed to fetch repos: \(error.localizedDescription)".logE()
        }
        
        return repos
    }
    
    func deleteRepo(byId id: Int, database: FMDatabase) {
        let deleteSQL = "DELETE FROM Repo WHERE id = ?;"
        
        do {
            try database.executeUpdate(deleteSQL, values: [id])
            "Deleted successfully".logI()
        } catch {
            "Failed to delete: \(error.localizedDescription)".logE()
        }
    }
}
