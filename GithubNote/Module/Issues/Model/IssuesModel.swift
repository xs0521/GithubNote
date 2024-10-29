//
//  IssuesModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation
import FMDB

enum IssueState: String, Codable {
    case open = "open"
    case closed = "closed"
}

struct Issue: APIModelable, Identifiable, Hashable, Equatable {
    
    var uuid: String?
    
    var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int?
    let url: String?
    let repositoryUrl: String?
    let number: Int?
    var title: String?
    let body: String?
    let state: IssueState?
    
    func filter() -> Bool {
        return state == .open
    }
}

extension Issue: SQLModelable {
    
    static var fetchSql: String {
        let tableName = CacheManager.shared.manager?.issueTableName() ?? ""
        return "SELECT * FROM \(tableName) WHERE repositoryUrl = ? ORDER BY sort;"
    }
    
    static func item(_ resultSet: FMResultSet) -> Issue {
        var issue = Issue(
            id: Int(resultSet.longLongInt(forColumn: "id")),
            url: resultSet.string(forColumn: "url"),
            repositoryUrl: resultSet.string(forColumn: "repositoryUrl"),
            number: Int(resultSet.int(forColumn: "number")),
            title: resultSet.string(forColumn: "title"),
            body: resultSet.string(forColumn: "body"),
            state: IssueState(rawValue: resultSet.string(forColumn: "state") ?? "open")
        )
        issue.defultModel()
        return issue
    }
    
    
    static var tableName: String {
        let tableName = CacheManager.shared.manager?.issueTableName() ?? ""
        assert(!tableName.isEmpty)
        return tableName
    }
    
    var insertSql: String {
        let insertSQL = """
        INSERT OR REPLACE INTO \(Self.tableName) (id, sort, url, repositoryUrl, number, title, body, state)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        return insertSQL
    }
    
    func insertValues(_ index: Int) -> [Any] {
        [
            self.id ?? NSNull(),
            index,
            self.url ?? NSNull(),
            self.repositoryUrl ?? NSNull(),
            self.number ?? NSNull(),
            self.title ?? NSNull(),
            self.body ?? NSNull(),
            self.state?.rawValue ?? NSNull()
        ]
    }
    
    var updateSql: String {
        let updateSQL = """
        UPDATE \(Self.tableName) SET url = ?, repositoryUrl = ?, number = ?, title = ?, body = ?, state = ?
        WHERE id = ?;
        """
        return updateSQL
    }
    
    func updateValues() -> [Any] {
        [
            self.url ?? NSNull(),
            self.repositoryUrl ?? NSNull(),
            self.number ?? NSNull(),
            self.title ?? NSNull(),
            self.body ?? NSNull(),
            self.state?.rawValue ?? NSNull(),
            self.id ?? NSNull()
        ]
    }
    
}
