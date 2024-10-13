//
//  CacheModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation
//import Cache

class CacheManager: Setupable {
    
    var manager: SQLManager?
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
    
    static let shared = CacheManager()
    
    static func setup() {
        
        CacheManager.shared.manager?.clear()
        CacheManager.shared.manager = SQLManager()
    }
    
//    static let shared = CacheManager()
//    let diskConfig = DiskConfig(name: Account.repo)
//    let memoryConfig = MemoryConfig(expiry: .never)
//    
//    var currentRepo: RepoModel? {
//        didSet {
//            "#cache# current repo \(currentRepo?.name ?? "")".logI()
//        }
//    }
//    var currentIssue: Issue? {
//        didSet {
//            "#cache# current issue \(currentIssue?.title ?? "")".logI()
//        }
//    }
//    
//    lazy var store: Storage<String, Data?> = {
//        let storage = try? Storage<String, Data?>(
//          diskConfig: diskConfig,
//          memoryConfig: memoryConfig,
//          transformer: TransformerFactory.forCodable(ofType: Data?.self)
//        )
//        return storage!
//    }()
//    
//    func updateComments(_ list: [Comment], issueId: Int) -> Void {
//        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
//        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//        guard let path = API.comments(issueId: issueId, page: 1).cachePath else { return }
//        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
//    }
//    
//    func updateIssues(_ list: [Issue], repoName: String) -> Void {
//        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
//        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//        guard let path = API.repoIssues(repoName: repoName, page: 1).cachePath else { return }
//        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
//    }
//    
//    func updateImages(_ list: [GithubImage], repoName: String) -> Void {
//        let data = list.compactMap({$0.data()}).compactMap({$0.anyObj()})
//        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//        guard let path = API.repoImages(page: 1).cachePath else { return }
//        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
//    }
//    
//    func appendImage(_ image: GithubImage, repoName: String) -> Void {
//        
//        guard let path = API.repoImages(page: 1).cachePath else { return }
//        let data = try? CacheManager.shared.store.object(forKey: path)
//        
//        var modelList = [GithubImage]()
//        
//        if let data = data {
//            let json = try? JSONSerialization.jsonObject(with: data, options: [])
//            if let list = json as? [[String: Any]] {
//                let generator = ModelGenerator<GithubImage>()
//                let values = list.compactMap({generator.handle($0)})
//                modelList.append(contentsOf: values)
//            }
//        }
//        
//        modelList.append(image)
//        
//        let saveData = modelList.compactMap({$0.data()}).compactMap({$0.anyObj()})
//        let jsonData = try? JSONSerialization.data(withJSONObject: saveData, options: .prettyPrinted)
//        try? CacheManager.shared.store.setObject(jsonData, forKey: path)
//    }
    
}


extension CacheManager {
    
    static func insertRepos(repos: [RepoModel], completion: CommonCallBack? = nil) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            CacheManager.shared.manager?.insertRepos(repos: repos, database: database)
            DispatchQueue.main.async {
                completion?()
            }
        })
    }
    
    static func fetchRepos(_ completion: @escaping CommonTCallBack<[RepoModel]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let models = CacheManager.shared.manager?.fetchRepos(database: database)
            DispatchQueue.main.async {
                completion(models ?? [])
            }
        })
    }
    
    static func deleteRepo(_ id: Int, _ completion: @escaping CommonTCallBack<[RepoModel]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            CacheManager.shared.manager?.deleteRepo(byId: id, database: database)
        })
    }
}

extension CacheManager {
    
    static func insertIssues(issues: [Issue], deleteNoFound: Bool = false, completion: CommonCallBack? = nil) -> Void {
        
        if deleteNoFound {
            fetchIssues { localList in
                let deleteList = localList.filter { item in
                    !issues.contains(where: {$0.id == item.id})
                }.compactMap({$0.id})
                "#insertIssues# delete \(deleteList.map({String($0)}).joined(separator: ","))".logI()
                deleteIssue(deleteList) {
                    insertAction()
                }
            }
            return
        } else {
            insertAction()
        }
        
        func insertAction() -> Void {
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                CacheManager.shared.manager?.createIssueTable()
                let tableName = CacheManager.shared.manager?.issueTableName()
                CacheManager.shared.manager?.insertIssue(issues: issues, into: tableName, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    static func fetchIssues(_ completion: @escaping CommonTCallBack<[Issue]>) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.issueTableName()
            let url = CacheManager.shared.currentRepo?.url ?? ""
            assert(!url.isEmpty, "url error")
            let models = CacheManager.shared.manager?.fetchIssues(from: tableName, where: url, database: database) ?? []
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    static func updateIssues(_ list: [Issue], _ completion: @escaping CommonCallBack) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.issueTableName()
            CacheManager.shared.manager?.updateIssues(issues: list, in: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    static func deleteIssue(_ ids: [Int], _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            guard let manager = CacheManager.shared.manager else { return }
            let tableName = manager.issueTableName()
            CacheManager.shared.manager?.deleteIssue(byId: ids, from: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}


extension CacheManager {
    
    static func insertComments(comments: [Comment], deleteNoFound: Bool = false, completion: CommonCallBack? = nil) -> Void {
        
        if deleteNoFound {
            fetchComments { localList in
                let deleteList = localList.filter { item in
                    !comments.contains(where: {$0.id == item.id})
                }.compactMap({$0.id})
                "#insertComments# delete \(deleteList.map({String($0)}).joined(separator: ","))".logI()
                deleteComment(deleteList) {
                    insertAction()
                }
            }
        } else {
            insertAction()
        }
        
        func insertAction() -> Void {
            
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                CacheManager.shared.manager?.createCommentTable()
                let tableName = CacheManager.shared.manager?.commentTableName()
                CacheManager.shared.manager?.insertComments(comments: comments, into: tableName, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
        
    }
    
    static func fetchComments(_ completion: @escaping CommonTCallBack<[Comment]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.commentTableName()
            let url = CacheManager.shared.currentIssue?.url ?? ""
            assert(!url.isEmpty, "url error")
            let models = CacheManager.shared.manager?.fetchComments(from: tableName, where: url, database: database) ?? []
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    static func updateComments(_ list: [Comment], _ completion: @escaping CommonCallBack) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.commentTableName()
            CacheManager.shared.manager?.updateComments(comments: list, in: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    static func deleteComment(_ ids: [Int], _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.commentTableName()
            CacheManager.shared.manager?.deleteComment(byId: ids, from: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    static func deleteComment(_ url: String, _ tableName: String, _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            CacheManager.shared.manager?.deleteComment(byIssueUrl: url, from: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}
