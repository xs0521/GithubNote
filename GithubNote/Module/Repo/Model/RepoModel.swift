//
//  RepoModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation
import FMDB

struct RepoModel: APIModelable, Identifiable, Hashable, Equatable {
    
    var uuid: String?
    
    var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: RepoModel, rhs: RepoModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int?
    let name, fullName, url: String?
    let createdAt, updatedAt, pushedAt: String?
    let `private`: Bool?
}

extension RepoModel: SQLModelable {
    
    static var fetchWhere: String? {
        nil
    }
    
    static func insertPreAction() { }
    
    static var fetchSql: String {
        "SELECT * FROM \(tableName) ORDER BY sort;"
    }
    
    static func item(_ resultSet: FMResultSet) -> RepoModel {
        RepoModel(
            id: Int(resultSet.longLongInt(forColumn: "id")),
            name: resultSet.string(forColumn: "name"),
            fullName: resultSet.string(forColumn: "fullName"),
            url: resultSet.string(forColumn: "url"),
            createdAt: resultSet.string(forColumn: "createdAt"),
            updatedAt: resultSet.string(forColumn: "updatedAt"),
            pushedAt: resultSet.string(forColumn: "pushedAt"),
            private: resultSet.bool(forColumn: "private")
        )
    }
    
    
    static var tableName: String {
        "Repo"
    }
    
    var insertSql: String {
        let insertOrUpdateSQL = """
        INSERT OR REPLACE INTO \(Self.tableName) (id, sort, name, fullName, url, createdAt, updatedAt, pushedAt, private)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        return insertOrUpdateSQL
    }
    
    func insertValues(_ index: Int) -> [Any] {
        [
            self.id ?? NSNull(),
            index,
            self.name ?? NSNull(),
            self.fullName ?? NSNull(),
            self.url ?? NSNull(),
            self.createdAt ?? NSNull(),
            self.updatedAt ?? NSNull(),
            self.pushedAt ?? NSNull(),
            self.private?.intValue ?? NSNull()
        ]
    }
    
    var updateSql: String {
        let updateSQL = """
        UPDATE \(Self.tableName)
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
        return updateSQL
    }
    
    func updateValues() -> [Any] {
        [
            self.name ?? NSNull(),
            self.fullName ?? NSNull(),
            self.url ?? NSNull(),
            self.createdAt ?? NSNull(),
            self.updatedAt ?? NSNull(),
            self.pushedAt ?? NSNull(),
            self.private ?? NSNull(),
            self.id ?? NSNull()
        ]
    }
}
