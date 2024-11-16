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
        
        CustomHeaderView(title: "NoteBook",
                         isNewSending: $isNewSending,
                         isRefreshing: $isRefreshing) {
            if !enbleAction() {
                return
            }
            alertStore.show(desc: "If the content is not available on the remote, syncing will automatically delete the local notes.") {
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
            ToastManager.shared.show("Please select a workspace")
            return false
        }
        return true
    }
}

