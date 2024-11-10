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
    @Published var editMarkdownString: String?
    @Published var cache: String = ""
    @Published var cacheUpdate: Int = 0
    
    @Published var updateAt: String? = ""
    
    var body: String? = ""
    
    private var workItem: DispatchWorkItem?
    
    func updateEditText(_ content: String?, _ updateLocal: Bool) -> Void {
        if updateLocal {
            let text = content ?? ""
            if text != editMarkdownString {
                debounceUpdateCacheText(text)
            }
        }
        editMarkdownString = content
    }
    
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
            self.cache = comment?.cache ?? ""
            self.cacheUpdate = comment?.cacheUpdate ?? 0
            self.updateAt = comment?.updatedAt ?? ""
            
            let content = comment?.cache ?? comment?.body
            self.body = comment?.body
            self.markdownString = content
            self.updateEditText(content, false)
        }
    }
}
