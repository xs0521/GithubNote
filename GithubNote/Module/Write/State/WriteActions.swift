//
//  WriteActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import SwiftUIFlux

struct WriteActions {
    
    struct edit: Action {
        let editIsShown: Bool
    }
    
    struct uploadState: Action {
        let value: UploadType
    }
    
    struct upload: AsyncAction {
        
        let completion: CommonTCallBack<Bool>
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            updateContent(completion)
        }
        
        private func updateContent(_ completion: @escaping CommonTCallBack<Bool>) -> Void {
            guard let body = writeStore.editMarkdownString ?? writeStore.markdownString, let commentid = commentStore.select?.id else { return }
            
            Networking<Comment>().request(API.updateComment(commentId: commentid, body: body), parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
                
                guard let comment = data?.first else {
                    completion(false)
                    return
                }
                
                updateCommentData(comment) {
                    completion(true)
                }
                
            }
        }
        
        private func updateCommentData(_ comment: Comment, _ completion: @escaping CommonCallBack) -> Void {
            CacheManager.update([comment]) {
                CacheManager.fetchList { localList in
                    commentStore.select = localList.first(where: {$0.id == comment.id})
                    store.dispatch(action: CommentActions.SetList(list: localList))
                    completion()
                }
            }
        }
    }
}
