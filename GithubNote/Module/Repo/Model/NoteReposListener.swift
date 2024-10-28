//
//  NoteReposListener.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation

class NoteReposListener {
    
    func loadPage(_ cache: Bool = true) {
        store.dispatch(action: ReposActions.FetchList(readCache: cache))
    }
}
