//
//  CommentModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation
import FMDB

struct Comment: APIModelable, Identifiable, Hashable, Equatable {
    
    var id: Int?
    var url, htmlUrl, issueUrl: String?
    var nodeId: String?
    var createdAt, updatedAt: String?
    var body: String?
    var uuid: String?
    ///only local
    var cache: String?
    var cacheUpdate: Int?
    
    public var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    public static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Comment: SQLModelable {
    
    static var fetchWhere: String? {
        CacheManager.shared.currentIssue?.url ?? ""
    }
    
    static func insertPreAction() {
        CacheManager.shared.manager?.createCommentTable()
    }
    
    static var fetchSql: String {
        let tableName = CacheManager.shared.manager?.commentTableName() ?? ""
        return "SELECT * FROM \(tableName) WHERE issueURL = ? ORDER BY sort;"
    }
    
    static func item(_ resultSet: FMResultSet) -> Comment {
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
        return comment
    }
    
    
    static var tableName: String {
        let tableName = CacheManager.shared.manager?.commentTableName() ?? ""
        assert(!tableName.isEmpty)
        return tableName
    }
    
    var insertSql: String {
        let insertSQL = """
        INSERT OR REPLACE INTO \(Self.tableName) (id, sort, url, htmlURL, issueURL, nodeID, createdAt, updatedAt, body)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        return insertSQL
    }
    
    func insertValues(_ index: Int) -> [Any] {
        [
            self.id ?? NSNull(),
            index,
            self.url ?? NSNull(),
            self.htmlUrl ?? NSNull(),
            self.issueUrl ?? NSNull(),
            self.nodeId ?? NSNull(),
            self.createdAt ?? NSNull(),
            self.updatedAt ?? NSNull(),
            self.body ?? NSNull()
        ]
    }
    
    var updateSql: String {
        let updateSQL = """
        UPDATE \(Self.tableName) SET url = ?, htmlURL = ?, issueURL = ?, nodeID = ?, createdAt = ?, updatedAt = ?, body = ?
        WHERE id = ?;
        """
        return updateSQL
    }
    
    func updateValues() -> [Any] {
        [
            self.url ?? NSNull(),
            self.htmlUrl ?? NSNull(),
            self.issueUrl ?? NSNull(),
            self.nodeId ?? NSNull(),
            self.createdAt ?? NSNull(),
            self.updatedAt ?? NSNull(),
            self.body ?? NSNull(),
            self.id ?? NSNull()
        ]
    }
    
}
