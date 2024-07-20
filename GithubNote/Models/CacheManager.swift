//
//  CacheModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation
import Cache

class CacheManager {
    
    static let shared = CacheManager()
    let diskConfig = DiskConfig(name: Account.repo)
    let memoryConfig = MemoryConfig(expiry: .never)
    
    lazy var store: Storage<String, Data?> = {
        let storage = try? Storage<String, Data?>(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          transformer: TransformerFactory.forCodable(ofType: Data?.self) // Storage<String, User>
        )
        return storage!
    }()
}
