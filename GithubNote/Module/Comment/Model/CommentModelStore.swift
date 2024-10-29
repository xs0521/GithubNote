//
//  CommentModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/29.
//

import Foundation
import Combine
import SwiftUI

final class CommentModelStore: ObservableObject {
    
    let listener: CommentListener
    
    @Published var select: Comment? {
        didSet {
            AppUserDefaults.comment = select
//            store.dispatch(action: IssuesActions.WillEditAction(issue: nil))
        }
    }
    
    @Published var editText: String = ""
        
    init(select: Comment?) {
        self.select = select
        self.listener = CommentListener()
    }
}
