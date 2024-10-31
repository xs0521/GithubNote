//
//  CacheModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation

class CacheManager: Setupable {
    
    var manager: SQLManager?
    var currentRepo: RepoModel? {
        get {
            AppUserDefaults.repo
        }
    }
    var currentIssue: Issue? {
        get {
            AppUserDefaults.issue
        }
    }
    
    static let shared = CacheManager()
    
    static func setup() {
        
        CacheManager.shared.manager?.clear()
        CacheManager.shared.manager = SQLManager()
    }
    
}

extension CacheManager {
    
    static func fetchList<T: SQLModelable>(_ completion: @escaping CommonTCallBack<[T]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let models = CacheManager.shared.manager?.fetchItems(database: database, where: T.fetchWhere) ?? [T]()
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    static func insert<T: SQLModelable>(items: [T], deleteNoFound: Bool = false, completion: CommonCallBack? = nil) -> Void {
        
        func insertAction() {
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                T.insertPreAction()
                CacheManager.shared.manager?.insertItems(items: items, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
        
        if !deleteNoFound {
            insertAction()
            return
        }
        
        delete(items, true) {
            insertAction()
        }
    }
    
    static func delete<T: SQLModelable>(_ items: [T], _ notInItems: Bool = false, _ completion: @escaping CommonCallBack) -> Void {
        
        if notInItems {
            fetchList { localList in
                let localList = localList as [T]
                let deleteList = localList.filter { item in
                    !items.contains(where: {$0.id == item.id})
                }.compactMap({$0.id})
                execute(deleteList)
            }
        } else {
            let deleteList = items.compactMap({$0.id})
            execute(deleteList)
        }
        
        func execute(_ ids: [Int]) {
            
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                CacheManager.shared.manager?.deleteItems(in: T.tableName, byId: ids, database: database)
                DispatchQueue.main.async {
                    completion()
                }
            })
        }
    }
    
    static func update<T: SQLModelable>(_ list: [T], _ completion: @escaping CommonCallBack) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            CacheManager.shared.manager?.updateItems(items: list, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}

extension CacheManager {
    
    static func fetchComment(_ id: NSInteger,  _ completion: @escaping CommonTCallBack<Comment?>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.commentTableName()
            let model = CacheManager.shared.manager?.fetchComment(from: tableName, where: id, database: database)
            DispatchQueue.main.async {
                completion(model)
            }
        })
    }
    
    static func updateCommentCache(_ comment: Comment, _ completion: @escaping CommonCallBack) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            var comment = comment
            comment.cacheUpdate = Int(Date().timeIntervalSince1970)
            let tableName = CacheManager.shared.manager?.commentTableName()
            CacheManager.shared.manager?.updateCommentCache(comment: comment, in: tableName, database: database)
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

extension CacheManager {
    
    // 插入 GithubImage
    static func insertGithubImages(images: [GithubImage], deleteNoFound: Bool = false, completion: CommonCallBack? = nil) -> Void {
        
        if !deleteNoFound {
            insertAction {
                completion?()
            }
            return
        }
        
        deleteAllGithubImage {
            insertAction {
                completion?()
            }
        }
        
        func insertAction(completion: CommonCallBack? = nil) -> Void {
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                CacheManager.shared.manager?.createImagesTable()
                let tableName = CacheManager.shared.manager?.imagesTableName()
                CacheManager.shared.manager?.insertGithubImages(images: images, into: tableName, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    // 查询单个 GithubImage
    static func fetchGithubImage(_ id: String, _ completion: @escaping CommonTCallBack<GithubImage?>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.imagesTableName()
            let model = CacheManager.shared.manager?.fetchGithubImage(from: tableName, where: id, database: database)
            DispatchQueue.main.async {
                completion(model)
            }
        })
    }
    
    // 查询多个 GithubImages
    static func fetchGithubImages(_ completion: @escaping CommonTCallBack<[GithubImage]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.imagesTableName()
            let models = CacheManager.shared.manager?.fetchGithubImages(from: tableName, database: database) ?? []
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    // 删除指定 ID 的 GithubImages
    static func deleteGithubImages(_ urls: [String], _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.imagesTableName()
            CacheManager.shared.manager?.deleteGithubImage(byUrls: urls, from: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    // 删除指定 URL 的 GithubImages
    static func deleteGithubImage(_ url: String, _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.imagesTableName()
            CacheManager.shared.manager?.deleteGithubImage(byUrls: [url], from: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    // 删除指定 URL 的 GithubImages
    static func deleteAllGithubImage(_ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.imagesTableName()
            CacheManager.shared.manager?.deleteAllGithubImage(from: tableName, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}
