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

            writeStore.cache = ""
            writeStore.checkCacheData()
            store.dispatch(action: WriteActions.edit(editIsShown: false))
            
        }
    }
    
    @Published var editText: String = ""
        
    init(select: Comment?) {
        self.select = select
        self.listener = CommentListener()
    }
}
