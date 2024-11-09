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
    
    @Published var markdownString: String?
    @Published var editMarkdownString: String? {
        didSet {
            if let text = editMarkdownString, text != oldValue {
                debounceUpdateCacheText(text)
            }
        }
    }
    @Published var cache: String = ""
    @Published var cacheUpdate: Int = 0
    
    private var workItem: DispatchWorkItem?
    
    func debounceUpdateCacheText(_ text: String) {
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.updateCacheText(text)
        }
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    fileprivate func updateCacheText(_ text: String) {
        guard var comment = commentStore.select else { return }
        if comment.cache == text {
            return
        }
        comment.cache = text
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
