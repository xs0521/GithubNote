//
//  NoteCommentsHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteCommentsHeaderView: View {
    
    @EnvironmentObject var alertStore: AlertModelStore
    
    @State private var isNewSending: Bool = false
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        
        CustomHeaderView(title: "note".language(),
                         isNewSending: $isNewSending,
                         isRefreshing: $isRefreshing) {
            
            if !enbleAction() {
                return
            }
            
            alertStore.show(desc: "download_tip".language()) {
                isRefreshing = true
                store.dispatch(action: CommentActions.FetchList(readCache: false, showTip: true, completion: { finish in
                    isRefreshing = false
                }))
            } onCancel: {
                
            }
            
        } newCallBack: {
            if !enbleAction() {
                return
            }
            isNewSending = true
            store.dispatch(action: CommentActions.Create(completion: { finish in
                store.dispatch(action: CommentActions.FetchList(readCache: true, completion: { _ in
                    isNewSending = false
                }))
            }))
        }

    }
    
    func enbleAction() -> Bool {
        if AppUserDefaults.issue == nil {
            ToastManager.shared.show("select_notebook".language())
            return false
        }
        return true
    }
}
