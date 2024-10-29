//
//  CommentListener.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/29.
//

import Foundation

class CommentListener {
    
    func loadPage(_ cache: Bool = true, _ completion: CommonTCallBack<Bool>? = nil) {
        store.dispatch(action: CommentActions.FetchList(readCache: cache, completion: completion))
    }
}
