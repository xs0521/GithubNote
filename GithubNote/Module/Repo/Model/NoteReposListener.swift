//
//  NoteReposListener.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation

class NoteReposListener {
    
    func loadPage(_ cache: Bool = true, _ completion: CommonTCallBack<Bool>? = nil) {
        store.dispatch(action: ReposActions.FetchList(readCache: cache, completion: completion))
    }
    
    func create(_ completion: CommonTCallBack<Bool>? = nil) -> Void {
        store.dispatch(action: ReposActions.CreateRepo(completion: completion))
    }
}
