//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AlertToast

struct NoteContentView: View {
    
    
    @State private var selectionRepo: RepoModel?
    
    
    @State private var selectionIssue: Issue?
    
    @State private var allComment = [Comment]()
    @State private var selectionComment: Comment?
    
    @State private var userCreatedGroups: [RepoModel] = [RepoModel]()
    @State private var searchTerm: String = ""
    
    @State private var markdownString: String? = ""
    @State private var showImageBrowser: Bool? = false
    
    @State private var progressValue: Double = 0.0
    
    @State private var showLoading: Bool = false
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastItem: ToastItem?
    
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                NoteSidebarView(userCreatedGroups: $userCreatedGroups,
                                selectionRepo: $selectionRepo,
                                selectionIssue: $selectionIssue,
                                commentGroups: $allComment,
                                selectionComment: $selectionComment, 
                                showImageBrowser: $showImageBrowser)
              
            } detail: {
                NoteWritePannelView(commentGroups: $allComment,
                                          comment: $selectionComment,
                                            issue: $selectionIssue,
                                 showImageBrowser: $showImageBrowser,
                                      showLoading: $showLoading)
                .background(Color.white)
            }
            .blur(radius: (showImageBrowser ?? false) ? 5 : 0, opaque: true)
            .onAppear(perform: {
                ToastManager.shared.homeCallBack = { (item) in
                    toastItem = item
                    showToast = true
                }
            })
            .toast(isPresenting: $showToast, duration: 2.0, tapToDismiss: true){
                AlertToast(displayMode: toastItem?.mode ?? .hud, type: toastItem?.type ?? .regular, title: toastItem?.title ?? "")
            }
            .toast(isPresenting: $showLoading){
                AlertToast(type: .loading, title: nil, subTitle: nil)
            }
            if showImageBrowser! {
                NoteImageBrowserView(showImageBrowser: $showImageBrowser, 
                                     progressValue: $progressValue,
                                     showToast: $showToast,
                                     toastMessage: $toastMessage,
                                     showLoading: $showLoading)
            }
            
        }
    }
}
