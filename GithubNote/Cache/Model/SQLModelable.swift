//
//  SQLModelable.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/22.
//

import Foundation
import FMDB

protocol SQLModelable {
    
    static var tableName: String { get }
    
    func maxIndex(_ database: FMDatabase) -> Int
    
    var insertSql: String { get }
    func insertValues(_ index: Int) -> [Any]
    
    static var fetchSql: String { get }
    static func item(_ resultSet: FMResultSet) -> Self
    
    var updateSql: String { get }
    func updateValues() -> [Any]
}

extension SQLModelable {
    
    func maxIndex(_ database: FMDatabase) -> Int {
        CacheManager.shared.manager?.getMaxIndex(Self.tableName, from: database) ?? 0
    }
}