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
    @State private var toastItem: ToastItem?
    
    @State private var repoPage = 1
    
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
                                issueSyncCallBack: { callBack in requestIssue(false, callBack)},
                                reposSyncCallBack: { callBack in
                    repoPage = 1
                    requestRepo(repoPage, false, callBack)
                }, reposMoreCallBack: { callBack in
                    repoPage += 1
                    requestRepo(repoPage, false, callBack)
                })
              
            } detail: {
                NoteWritePannelView(commentGroups: $allComment,
                                          comment: $selectionComment,
                                            issue: $selectionIssue,
                                 showImageBrowser: $showImageBrowser,
                                      showLoading: $showLoading)
                .background(Color.white)
            }
            .onAppear(perform: {
                ToastManager.shared.homeCallBack = { (item) in
                    toastItem = item
                    showToast = true
                }
                requestRepo(repoPage) {_, _ in
                }
            })
            .onChange(of: selectionRepo) { oldValue, newValue in
                if oldValue != newValue {
                    requestIssue {}
                }
            }
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

extension NoteContentView {
    
    private func requestRepo(_ page: Int, _ readCache: Bool = true, _ completion: @escaping RequestCallBack) -> Void {
        Networking<RepoModel>().request(API.repos(page: page), readCache: readCache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            
            guard let list = data else {
                completion(false, false)
                return
            }
            
            if let owner = list.first?.fullName?.split(separator: "/").first {
                "#repo# owner \(owner) - \(Account.owner)".logI()
                if owner != Account.owner {
                    ToastManager.shared.showFail("owner error")
                }
            }
            
            if page <= 1 {
                allRepo.removeAll()
            }
            
            allRepo.append(contentsOf: list)
            if let repo = allRepo.first(where: {$0.name == Account.repo}) {
                selectionRepo = repo
                completion(true, !list.isEmpty)
                return
            }
            if let firstRepo = allRepo.first {
                selectionRepo = firstRepo
                completion(true, !list.isEmpty)
                return
            }
            completion(true, !list.isEmpty)
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
