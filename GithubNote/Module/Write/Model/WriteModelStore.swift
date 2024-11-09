//
//  WriteModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import Combine
import SwiftUI

final class WriteModelStore: ObservableObject {
    
    @Published var markdownString: String? {
        didSet {
            debounceUpdateCacheText()
        }
    }
    
    @Published var editMarkdownString: String?
    
    @Published var cache: String = ""
    @Published var cacheUpdate: Int = 0
    
    var workItem: DispatchWorkItem?
    
    func debounceUpdateCacheText() {
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.updateCacheText()
        }
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    fileprivate func updateCacheText() {
        guard var comment = commentStore.select else { return }
        if writeStore.markdownString == comment.cache {
            return
        }
        comment.cache = writeStore.markdownString
        CacheManager.updateCommentCache(byComment: comment) {}
    }
    
    func checkCacheData() -> Void {
        guard let commentId = AppUserDefaults.comment?.id else { return }
        CacheManager.fetchComment(byId: commentId) { comment in
            writeStore.cache = comment?.cache ?? ""
            writeStore.cacheUpdate = comment?.cacheUpdate ?? 0
        }
    }
}
