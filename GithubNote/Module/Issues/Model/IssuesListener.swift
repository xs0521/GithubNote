//
//  NoteIssuesListener.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/28.
//

import Foundation

class IssuesListener {
    
    func loadPage(_ cache: Bool = true, _ completion: CommonTCallBack<Bool>? = nil) {
        store.dispatch(action: IssuesActions.FetchList(readCache: cache, completion: completion))
    }
    
    func create(_ completion: CommonTCallBack<Bool>? = nil) -> Void {
//        store.dispatch(action: ReposActions.CreateRepo(completion: completion))
    }
    
    
}
