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
    
    var currentRepo: RepoModel? {
        didSet {
            "#cache# current repo \(currentRepo?.name ?? "")".logI()
        }
    }
    var currentIssue: Issue? {
        didSet {
            "#cache# current issue \(currentIssue?.title ?? "")".logI()
        }
    }
    
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
        guard let path = API.comments(issueId: issueId, page: 1).cachePath else { return }
        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
    }
    
    func updateIssues(_ list: [Issue], repoName: String) -> Void {
        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        guard let path = API.repoIssues(repoName: repoName, page: 1).cachePath else { return }
        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
    }
    
    func updateImages(_ list: [GithubImage], repoName: String) -> Void {
        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        guard let path = API.repoImages(page: 1).cachePath else { return }
        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
    }
    
    func appendImage(_ image: GithubImage, repoName: String) -> Void {
        
        guard let path = API.repoImages(page: 1).cachePath else { return }
        let data = try? CacheManager.shared.store.object(forKey: path)
        
        var modelList = [GithubImage]()
        
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let list = json as? [[String: Any]] {
                let generator = ModelGenerator<GithubImage>()
                let values = list.compactMap({generator.handle($0)})
                modelList.append(contentsOf: values)
            }
        }
        
        modelList.append(image)
        
        let saveData = modelList.compactMap({$0.data()}).compactMap({$0.anyObj()})
        let jsonData = try? JSONSerialization.data(withJSONObject: saveData, options: .prettyPrinted)
        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
    }
    
}


extension CacheManager {
    
    static func insertRepos(repos: [RepoModel]) -> Void {
        SQLManager.shared.dbQueue?.inDatabase({ database in
            SQLManager.shared.insertRepos(repos: repos, database: database)
        })
    }
    
    static func fetchRepos(_ completion: @escaping CommonTCallBack<[RepoModel]>) -> Void {
        SQLManager.shared.dbQueue?.inDatabase({ database in
            let models = SQLManager.shared.fetchRepos(database: database)
            completion(models)
        })
    }
    
    static func deleteRepo(_ id: Int, _ completion: @escaping CommonTCallBack<[RepoModel]>) -> Void {
        SQLManager.shared.dbQueue?.inDatabase({ database in
            SQLManager.shared.deleteRepo(byId: id, database: database)
        })
    }
}

extension CacheManager {
    
    static func insertIssues(issues: [Issue]) -> Void {
        SQLManager.shared.dbQueue?.inDatabase({ database in
            SQLManager.shared.createIssueTable()
            let tableName = SQLManager.shared.issueTableName()
            SQLManager.shared.insertIssue(issues: issues, into: tableName, database: database)
        })
        
    }
    
    static func fetchIssues(_ completion: @escaping CommonTCallBack<[Issue]>) -> Void {
        let tableName = SQLManager.shared.issueTableName()
        let url = CacheManager.shared.currentRepo?.url ?? ""
        assert(!url.isEmpty, "url error")
        SQLManager.shared.dbQueue?.inDatabase({ database in
            let models = SQLManager.shared.fetchIssues(from: tableName, where: url, database: database)
            completion(models)
        })
    }
    
    static func deleteIssue(_ id: Int, _ completion: @escaping CommonTCallBack<[Issue]>) -> Void {
        let tableName = SQLManager.shared.issueTableName()
        SQLManager.shared.dbQueue?.inDatabase({ database in
            SQLManager.shared.deleteIssue(byId: id, from: tableName, database: database)
        })
    }
}


extension CacheManager {
    
    static func insertComments(comments: [Comment]) -> Void {
        SQLManager.shared.dbQueue?.inDatabase({ database in
            SQLManager.shared.createCommentTable()
            let tableName = SQLManager.shared.commentTableName()
            SQLManager.shared.insertComments(comments: comments, into: tableName, database: database)
        })
        
    }
    
    static func fetchComments(_ completion: @escaping CommonTCallBack<[Comment]>) -> Void {
        let tableName = SQLManager.shared.commentTableName()
        let url = CacheManager.shared.currentIssue?.url ?? ""
        assert(!url.isEmpty, "url error")
        SQLManager.shared.dbQueue?.inDatabase({ database in
            let models = SQLManager.shared.fetchComments(from: tableName, where: url, database: database)
            completion(models)
        })
    }
    
    static func deleteComment(_ id: Int, _ completion: @escaping CommonTCallBack<[Comment]>) -> Void {
        let tableName = SQLManager.shared.issueTableName()
        SQLManager.shared.dbQueue?.inDatabase({ database in
            SQLManager.shared.deleteIssue(byId: id, from: tableName, database: database)
        })
    }
}
