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
          transformer: TransformerFactory.forCodable(ofType: Data?.self)
        )
        return storage!
    }()
    
    func updateComments(_ list: [Comment], issueId: Int) -> Void {
        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        guard let path = API.comments(issueId: issueId).cachePath else { return }
        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
    }
    
    func updateIssues(_ list: [Issue], repoName: String) -> Void {
        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        guard let path = API.repoIssues(repoName: repoName).cachePath else { return }
        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
    }
}
