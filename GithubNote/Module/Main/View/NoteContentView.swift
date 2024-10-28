//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AlertToast


struct NoteContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectionRepo: RepoModel?
    
    @State private var selectionIssue: Issue?
    
    @State private var commentGroups = [Comment]()
    @State private var selectionComment: Comment?
    
    @State private var showImageBrowser: Bool? = false
    
    @State private var showLoading: Bool = false
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastItem: ToastItem?
    
    
    
    
    var body: some View {
        ZStack {
#if MOBILE
            VStack {
                NoteContentHeaderView()
                CustomDivider()
                NoteContentTableView(selectionRepo: $selectionRepo,
                                     selectionIssue: $selectionIssue,
                                     commentGroups: $commentGroups,
                                     selectionComment: $selectionComment)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
#else
            NavigationSplitView {
                sidebarView()
            } detail: {
                writePannelView()
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
#endif
            if showImageBrowser! {
                NoteImageBrowserView(showImageBrowser: $showImageBrowser,
                                     showToast: $showToast,
                                     toastMessage: $toastMessage,
                                     showLoading: $showLoading)
            }
            
        }
    }
    
    private func sidebarView() -> some View {
        NoteSidebarView(selectionRepo: $selectionRepo,
                        selectionIssue: $selectionIssue,
                        commentGroups: $commentGroups,
                        selectionComment: $selectionComment,
                        showImageBrowser: $showImageBrowser)
    }
    
    private func writePannelView() -> some View {
        ZStack {
            NoteWritePannelView(commentGroups: $commentGroups,
                                selectionRepo: $selectionRepo,
                               selectionIssue: $selectionIssue,
                             selectionComment: $selectionComment,
                                        issue: $selectionIssue,
                             showImageBrowser: $showImageBrowser,
                                  showLoading: $showLoading)
            if selectionComment == nil {
                NoteEmptyView()
                    .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
            }
        }
        .background(Color.white)
    }
}
