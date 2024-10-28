//
//  RepoModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation
import Combine
import SwiftUI

final class RepoModelStore: ObservableObject {
    
    let listener: NoteReposListener
    
    @Published var select: RepoModel? {
        didSet {
            if AppUserDefaults.repo != select && select != nil {
                store.dispatch(action: SideActions.ReposViewState(show: false))
            }
            AppUserDefaults.repo = select
        }
    }
        
    init(select: RepoModel?) {
        self.select = select
        self.listener = NoteReposListener()
    }
}
