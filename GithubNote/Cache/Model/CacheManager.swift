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
    
    static func insertRepos(repos: [RepoModel], deleteNoFound: Bool = false, completion: CommonCallBack? = nil) -> Void {
        
        func insertAction() {
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                CacheManager.shared.manager?.insertItems(items: repos, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
        
        if !deleteNoFound {
            insertAction()
            return
        }
        
        fetchRepos { localList in
            let deleteList = localList.filter { item in
                !repos.contains(where: {$0.id == item.id})
            }.compactMap({$0.id})
            "#insertRepo# delete \(deleteList.map({String($0)}).joined(separator: ","))".logI()
            deleteRepo(deleteList) {
                insertAction()
            }
        }
    }
    
    static func fetchRepos(_ completion: @escaping CommonTCallBack<[RepoModel]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let models = CacheManager.shared.manager?.fetchItems(database: database) ?? [RepoModel]()
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    static func deleteRepo(_ ids: [Int], _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = RepoModel.tableName
            CacheManager.shared.manager?.deleteItems(in: tableName, byId: ids, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}

extension CacheManager {
    
    static func insertIssues(issues: [Issue], deleteNoFound: Bool = false, completion: CommonCallBack? = nil) -> Void {
        
        func insertAction() -> Void {
            CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
                CacheManager.shared.manager?.createIssueTable()
                CacheManager.shared.manager?.insertItems(items: issues, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
        
        if !deleteNoFound {
            insertAction()
            return
        }
        
        fetchIssues { localList in
            let deleteList = localList.filter { item in
                !issues.contains(where: {$0.id == item.id})
            }.compactMap({$0.id})
            "#insertIssues# delete \(deleteList.map({String($0)}).joined(separator: ","))".logI()
            deleteIssue(deleteList) {
                insertAction()
            }
        }
    }
    
    static func fetchIssues(_ completion: @escaping CommonTCallBack<[Issue]>) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let repositoryUrl = CacheManager.shared.currentRepo?.url ?? ""
            assert(!repositoryUrl.isEmpty, "url error")
            let models = CacheManager.shared.manager?.fetchItems(database: database, where: repositoryUrl) ?? [Issue]()
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    static func updateIssues(_ list: [Issue], _ completion: @escaping CommonCallBack) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            CacheManager.shared.manager?.updateItems(items: list, database: database)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    static func deleteIssue(_ ids: [Int], _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            guard let manager = CacheManager.shared.manager else { return }
            let tableName = manager.issueTableName()
            CacheManager.shared.manager?.deleteItems(in: tableName, byId: ids, database: database)
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
                CacheManager.shared.manager?.insertItems(items: comments, database: database)
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    static func fetchComment(_ id: NSInteger,  _ completion: @escaping CommonTCallBack<Comment?>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.commentTableName()
            let model = CacheManager.shared.manager?.fetchComment(from: tableName, where: id, database: database)
            DispatchQueue.main.async {
                completion(model)
            }
        })
    }
    
    static func fetchComments(_ completion: @escaping CommonTCallBack<[Comment]>) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let issueURL = CacheManager.shared.currentIssue?.url ?? ""
            assert(!issueURL.isEmpty, "url error")
            let models = CacheManager.shared.manager?.fetchItems(database: database, where: issueURL) ?? [Comment]()
            DispatchQueue.main.async {
                completion(models)
            }
        })
    }
    
    static func updateComments(_ list: [Comment], _ completion: @escaping CommonCallBack) -> Void {
        
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            CacheManager.shared.manager?.updateItems(items: list, database: database)
            DispatchQueue.main.async {
                completion()
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
    
    static func deleteComment(_ ids: [Int], _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.shared.manager?.dbQueue?.inDatabase({ database in
            let tableName = CacheManager.shared.manager?.commentTableName() ?? ""
            assert(!tableName.isEmpty, "tableName error")
            CacheManager.shared.manager?.deleteItems(in: tableName, byId: ids, database: database)
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
