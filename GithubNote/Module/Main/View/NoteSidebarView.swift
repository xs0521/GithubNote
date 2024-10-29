//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import Combine
import SwiftUIFlux

#if MOBILE
import UIKit
#else
import AppKit
#endif

struct NoteSidebarView: ConnectedView {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var reposGroups: [RepoModel] = [RepoModel]()
    @State private var repoPage = 1
    @Binding var selectionRepo: RepoModel?
    
    @State private var issueGroups = [Issue]()
    @State private var issuePage = 1
    @Binding var selectionIssue: Issue?
    
    @Binding var commentGroups: [Comment]
    @State private var commentPage = 1
    @Binding var selectionComment: Comment?
    
    @Binding var showImageBrowser: Bool?
    
    @State private var showReposView: Bool = false
    
    @State private var isLoaded: Bool = false
    
    struct Props {
        let isReposVisible: Bool
        var selectionRepo: RepoModel?
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isReposVisible: state.sideStates.isReposVisible,
                     selectionRepo: state.sideStates.selectionRepo)
    }
    
    func body(props: Props) -> some View {
        VStack {
            ZStack {
                VStack (spacing: 0) {
                    NoteCommentsHeaderView(selectionIssue: $selectionIssue) { callBack in
                        requestAllComment(false) {
                            callBack()
                        }
                    } createCallBack: { comment, finishCallBack in
                        CacheManager.insertComments(comments: [comment]) {
                            CacheManager.fetchComments { localList in
                                let select = localList.first(where: {$0.id == comment.id})
                                DispatchQueue.main.async(execute: {
                                    commentGroups = localList
                                    selectionComment = select
                                    finishCallBack()
                                })
                            }
                        }
                    }
                    NoteCommentsView(commentGroups: $commentGroups,
                                     selectionComment: $selectionComment,
                                     selectionIssue: $selectionIssue)
                    Spacer()
                    NoteIssuesHeaderView()
                    NoteIssuesView()
//                    NoteIssuesView(issueGroups: $issueGroups,
//                                   selectionIssue: $selectionIssue,
//                                   selectionRepo: $selectionRepo,
//                                   showReposView: $showReposView) { issue in
//                        guard let issue = issue else {
//                            commentGroups.removeAll()
//                            return
//                        }
//                        CacheManager.shared.currentIssue = issue
//                        requestAllComment {}
//                    }
                }
    #if !MOBILE
                .frame(minWidth: 200)
    #endif
//                .onChange(of: selectionRepo) { oldValue, newValue in
//                    if oldValue != newValue {
//                        CacheManager.shared.currentRepo = selectionRepo
//                        requestAllIssue(true) {
//                            selectionComment = nil
//                        }
//                    }
//                }
                .onAppear {
                    if !isLoaded {
                        requestAllRepo {}
                        isLoaded = true
                    }
                }
                if props.isReposVisible {
    //                NoteReposView(reposGroups: $reposGroups, selectionRepo: $selectionRepo) {
    //                    requestAllRepo {}
    //                }
                    
                    NoteReposView()
                }
            }
        }
#if MOBILE
        .background(colorScheme == .dark ? Color.init(hex: "#1C1C1E") : Color.init(hex: "#F2F2F7"))
#endif
        .safeAreaInset(edge: .bottom) {
            NoteSidebarToolView()
//            NoteSidebarToolView(showReposView: $showReposView,
//                                showImageBrowser: $showImageBrowser,
//                                selectionRepo: $selectionRepo) { cache, callBack in
//                requestAllRepo(cache) {
//                    callBack()
//                }
//            }
        }
        .onAppear(perform: {
            
        })
    }
}

extension NoteSidebarView {
    
    private func requestAllRepo(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        
        if readCache {
            CacheManager.fetchRepos { list in
                "#request# Repo all cache \(list.count)".logI()
                reposGroups = list
//                if let repo = list.first(where: {$0.name == AppUserDefaults.repo?.name}) {
//                    selectionRepo = repo
//                }
                completion()
            }
            return
        }
        
        repoPage = 1
        let allRepos: [RepoModel] = []
        requestRepo(repoPage, allRepos, readCache, true) { netList, success, more in
            "#request# Repo all \(netList.count)".logI()
            CacheManager.insertRepos(repos: netList, deleteNoFound: true) {
                CacheManager.fetchRepos { list in
                    reposGroups = list
                    let container = reposGroups.contains { item in
                        item.name == selectionRepo?.name
                    }
                    if !container {
                        selectionRepo = reposGroups.first
                    }
                    completion()
                }
            }
        }
    }
    
    private func requestRepo(_ page: Int, _ repos: [RepoModel], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[RepoModel]>) -> Void {
        
        var repos = repos
        
        "#request# Repo start page \(page) readCache \(readCache) next \(next)".logI()
        
        Networking<RepoModel>().request(API.repos(page: page), parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            
            guard let list = data else {
                "#request# Repo page \(page) error".logE()
                completion(repos, false, false)
                return
            }
            
            "#request# Repo page \(page) \(list.count)".logI()
            
//            if let repo = list.first(where: {$0.name == AppUserDefaults.repo?.name}) {
//                selectionRepo = repo
//            }
            
            repos.append(contentsOf: list)
            
            if next {
                if list.isEmpty {
                    completion(repos, true, false)
                } else {
                    repoPage += 1
                    requestRepo(repoPage, repos, false, next, completion)
                }
            } else {
                completion(repos, true, !list.isEmpty)
            }
        }
    }
}


extension NoteSidebarView {
    
    private func requestAllIssue(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        
        if selectionRepo == nil {
            ToastManager.shared.show("Please select a code repository")
            completion()
            return
        }
        
        if readCache {
            CacheManager.fetchIssues { list in
                "#request# issue all cache \(list.count)".logI()
                issueGroups = list
                selectionIssue = list.first
                completion()
            }
            return
        }
        
        issuePage = 1
        let allIssue: [Issue] = []
        requestIssue(issuePage, allIssue, false, true) { loadList, success, more in
            "#request# issue all \(loadList.count)".logI()
            CacheManager.insertIssues(issues: loadList, deleteNoFound: true) {
                CacheManager.fetchIssues { list in
                    issueGroups = list
                    completion()
                }
            }
        }
    }
    
    private func requestIssue(_ page: Int, _ issues: [Issue], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[Issue]>) -> Void {
        guard let repoName = selectionRepo?.name else { return }
        
        var issues = issues
        
        "#request# Issue start page \(page) readCache \(readCache) next \(next) repoName \(repoName)".logI()
        
        Networking<Issue>().request(API.repoIssues(repoName: repoName, page: page),
                                    parseHandler: ModelGenerator(snakeCase: true, filter: true)) { (data, _, _) in
            guard let list = data else {
                "#request# Issue page \(page) error".logE()
                completion(issues, false, false)
                return
            }
            
            "#request# Issue page \(page) \(list.count)".logI()
            
            issues.append(contentsOf: list)
            
            if next {
                if list.isEmpty {
                    completion(issues, true, false)
                } else {
                    issuePage += 1
                    requestIssue(issuePage, issues, false, next, completion)
                }
            } else {
                completion(issues, true, !list.isEmpty)
            }
        }
    }
    
    private func requestAllComment(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        
        if selectionIssue == nil {
            ToastManager.shared.showFail("Please select a NoteBook")
            completion()
            return
        }
        
        if readCache {
            CacheManager.fetchComments { list in
                "#request# comment all cache \(list.count)".logI()
                commentGroups = list
                selectionComment = list.first
                completion()
            }
            return
        }
        
        commentPage = 1
        let allComment: [Comment] = []
        commentsData(commentPage, allComment, readCache, true) { list, success, more in
            "#request# comment all \(list.count)".logI()
            commentGroups = list
            CacheManager.insertComments(comments: list, deleteNoFound: true)
            completion()
        }
    }
    
    private func commentsData(_ page: Int, _ comments: [Comment], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[Comment]>) -> Void {
        guard let number = selectionIssue?.number else { return }
        
        var comments = comments
        
        "#request# comment start page \(page) readCache \(readCache) next \(next) number \(number)".logI()
        
        Networking<Comment>().request(API.comments(issueId: number, page: commentPage), parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            guard let list = data else {
                "#request# comment page \(page) error".logE()
                completion(comments, false, false)
                return
            }
            
            "#request# comment page \(page) \(list.count)".logI()
            
            comments.append(contentsOf: list)
            
            if next {
                if list.isEmpty {
                    let item = comments.first(where: {$0.id == selectionComment?.id})
                    selectionComment = item
                    completion(comments, true, false)
                } else {
                    commentPage += 1
                    commentsData(commentPage, comments, false, next, completion)
                }
            } else {
                completion(comments, true, !list.isEmpty)
            }
            
        }
    }
}
