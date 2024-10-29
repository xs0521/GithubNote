//
//  CommentActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/29.
//

import Foundation
import SwiftUIFlux

struct CommentActions {
    
    class Config {
        var page = 1
        var list = [Comment]()
    }
    
    struct FetchList: AsyncAction {
        
        let readCache: Bool
        let config = Config()
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            requestAllComment(readCache) { finish in
                dispatch(SetList(list: config.list))
                completion?(finish)
            }
        }
        
        private func requestAllComment(_ readCache: Bool = true, _ completion: @escaping CommonTCallBack<Bool>) -> Void {
            
            if AppUserDefaults.issue == nil {
                ToastManager.shared.showFail("Please select a NoteBook")
                completion(false)
                return
            }
            
            if readCache {
                CacheManager.fetchComments { list in
                    "#request# comment all cache \(list.count)".logI()
                    config.list = list
                    completion(true)
                }
                return
            }
            
            config.page = 1
            let allComment: [Comment] = []
            commentsData(config.page, allComment, readCache, true) { list, success, more in
                "#request# comment all \(list.count)".logI()
                config.list = list
                CacheManager.insertComments(comments: list, deleteNoFound: true)
                completion(true)
            }
        }
        
        private func commentsData(_ page: Int, _ comments: [Comment], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[Comment]>) -> Void {
            guard let number = AppUserDefaults.issue?.number else { return }
            
            var comments = comments
            
            "#request# comment start page \(page) readCache \(readCache) next \(next) number \(number)".logI()
            
            Networking<Comment>().request(API.comments(issueId: number, page: page), parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
                guard let list = data else {
                    "#request# comment page \(page) error".logE()
                    completion(comments, false, false)
                    return
                }
                
                "#request# comment page \(page) \(list.count)".logI()
                
                comments.append(contentsOf: list)
                
                if next {
                    if list.isEmpty {
//                        let item = comments.first(where: {$0.id == selectionComment?.id})
                        completion(comments, true, false)
                    } else {
                        config.page += 1
                        commentsData(config.page, comments, false, next, completion)
                    }
                } else {
                    completion(comments, true, !list.isEmpty)
                }
                
            }
        }
    }
    
    struct Create: AsyncAction {
        
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            create { comment in
                guard let comment = comment else {
                    completion?(false)
                    return
                }
                CacheManager.insertComments(comments: [comment]) {
                    commentStore.select = comment
                    completion?(true)
                }
            }
        }
        
        func create(completion: @escaping CommonTCallBack<Comment?>) -> Void {
            
            if AppUserDefaults.issue == nil {
                ToastManager.shared.showFail("Please select a NoteBook")
                completion(nil)
                return
            }
            
            guard let issueId = AppUserDefaults.issue?.number else { return }
            let body = AppConst.markdown
            
            Networking<Comment>().request(API.newComment(issueId: issueId, body: body), parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
                guard let comment = data?.first else {
                    completion(nil)
                    return
                }
                completion(comment)
            }
        }
    }
    
    struct Delete: AsyncAction {
        
        let item: Comment
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            deleteComment(item) { finish in
                completion?(finish)
            }
        }
        
        private func deleteComment(_ comment: Comment, completion: @escaping CommonTCallBack<Bool>) -> Void {
            guard let commentId = comment.id else { return }
            Networking<Comment>().request(API.deleteComment(commentId: commentId)) { data, cache, code in
                if MessageCode.finish.rawValue != code {
                    completion(false)
                    return
                }
                CacheManager.deleteComment([commentId]) {
                    completion(true)
                }
            }
        }
    }
    
    struct WillDeleteAction: Action {
        let item: Comment?
    }
    
    struct SetList: Action {
        let list: [Comment]
    }
}
