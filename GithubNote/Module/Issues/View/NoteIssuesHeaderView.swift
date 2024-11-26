//
//  NoteIssuesHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteIssuesHeaderView: View {
    
    @EnvironmentObject var alertStore: AlertModelStore
    
    @State private var isNewSending: Bool = false
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        
        CustomHeaderView(title: "notebook".language(),
                         isNewSending: $isNewSending,
                         isRefreshing: $isRefreshing) {
            if !enbleAction() {
                return
            }
            alertStore.show(desc: "download_tip".language()) {
                isRefreshing = true
                store.dispatch(action: IssuesActions.FetchList(readCache: false, completion: { finish in
                    isRefreshing = false
                }))
            } onCancel: {
                
            }
        } newCallBack: {
            if !enbleAction() {
                return
            }
            isNewSending = true
            store.dispatch(action: IssuesActions.Create(completion: { finish in
                store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _ in
                    isNewSending = false
                }))
            }))
        }
    }
    
    func enbleAction() -> Bool {
        if AppUserDefaults.repo == nil {
            ToastManager.shared.show("select_workspace".language())
            alertStore.isRepoTipsVisible  = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                alertStore.isRepoTipsVisible  = false
            })
            return false
        }
        return true
    }
}

