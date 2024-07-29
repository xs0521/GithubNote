//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AlertToast

struct NoteContentView: View {
    
    @State private var allRepo: [RepoModel] = [RepoModel]()
    @State private var selectionRepo: RepoModel?
    
    @State private var allIssue = [Issue]()
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
    
    @State private var syncImages: Bool = false
    
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                NoteSidebarView(userCreatedGroups: $userCreatedGroups,
                                reposGroups: $allRepo,
                                selectionRepo: $selectionRepo,
                                issueGroups: $allIssue,
                                selectionIssue: $selectionIssue,
                                commentGroups: $allComment,
                                selectionComment: $selectionComment, 
                                showImageBrowser: $showImageBrowser,
                                issueSyncCallBack: { callBack in
                    requestIssue(false, callBack)
                })
              
            } detail: {
                NoteWritePannelView(commentGroups: $allComment,
                                          comment: $selectionComment,
                                            issue: $selectionIssue,
                                 showImageBrowser: $showImageBrowser,
                                    progressValue: $progressValue,
                                    syncImages: $syncImages)
                .background(Color.white)
            }
            .onAppear(perform: {
                requestRepo {}
            })
            .onChange(of: selectionRepo) { oldValue, newValue in
                if oldValue != newValue {
                    requestIssue {}
                }
            }
            .toast(isPresenting: $showToast, duration: 2.0, tapToDismiss: true){
                AlertToast(displayMode: .hud, type: .systemImage("party.popper", .primary), title: toastMessage)
            }
            .toast(isPresenting: $showLoading){
                AlertToast(type: .loading, title: nil, subTitle: nil)
            }
            if showImageBrowser! {
                NoteImageBrowserView(showImageBrowser: $showImageBrowser, 
                                     progressValue: $progressValue,
                                     showToast: $showToast,
                                     toastMessage: $toastMessage,
                                     showLoading: $showLoading, syncImages: $syncImages)
            }
            
        }
    }
}

extension NoteContentView {
    
    private func requestRepo(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        Networking<RepoModel>().request(API.repos, readCache: readCache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            guard let list = data, !list.isEmpty else {
                allRepo.removeAll()
                return
            }
            allRepo = list
            if let repo = allRepo.first(where: {$0.name == Account.repo}) {
                selectionRepo = repo
                return
            }
            if let firstRepo = allRepo.first {
                selectionRepo = firstRepo
                return
            }
        }
    }
    
    private func requestIssue(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        guard let repoName = selectionRepo?.name else { return }
        Networking<Issue>().request(API.repoIssues(repoName: repoName), readCache: readCache,
                                    parseHandler: ModelGenerator(snakeCase: true, filter: true)) { (data, _, _) in
            guard let list = data, !list.isEmpty else {
                allIssue.removeAll()
                return
            }
            allIssue = list
            completion()
        }
    }
}