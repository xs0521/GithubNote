//
//  IssueModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/28.
//

import Foundation
import Combine
import SwiftUI

final class IssueModelStore: ObservableObject {
    
    let listener: IssuesListener
    
    @Published var select: Issue? {
        didSet {
            let preSelect = AppUserDefaults.issue
            AppUserDefaults.issue = select
            commentStore.select = nil
            store.dispatch(action: IssuesActions.WillEditAction(item: nil))
            store.dispatch(action: CommentActions.FetchList(readCache: true, completion: nil))
            if preSelect != select {
                store.dispatch(action: SideActions.IssuesViewState(visible: false))
            }
        }
    }
    
    @Published var editText: String = ""
        
    init(select: Issue?) {
        self.select = select
        self.listener = IssuesListener()
    }
}
