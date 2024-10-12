//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AppKit

struct NoteSidebarView: View {
    
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
    
    @State private var isSyncRepos: Bool = false
    @State private var showReposView: Bool = false
    
    @State private var isLoaded: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
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
                NoteIssuesHeaderView() { callBack in
                    requestAllIssue(false) {
                        callBack()
                    }
                } createIssueCallBack: { issue in
                    CacheManager.insertIssues(issues: [issue]) {
                        CacheManager.fetchIssues { localList in
                            DispatchQueue.main.async {
                                issueGroups = localList
                                selectionIssue = localList.first(where: {$0.id == issue.id})
                            }
                        }
                    }
                }
                NoteIssuesView(issueGroups: $issueGroups,
                               selectionIssue: $selectionIssue,
                               selectionRepo: $selectionRepo,
                               showReposView: $showReposView) { issue in
                    guard let issue = issue else { return }
                    CacheManager.shared.currentIssue = issue
                    requestAllComment {}
                }
            }
            .frame(minWidth: 200)
            .onChange(of: selectionRepo) { oldValue, newValue in
                if oldValue != newValue {
                    CacheManager.shared.currentRepo = selectionRepo
                    requestAllIssue(true) { }
                }
            }
            .onAppear {
                if !isLoaded {
                    requestAllRepo {}
                    isLoaded = true
                }
            }
            if showReposView {
                NoteReposView(reposGroups: $reposGroups, selectionRepo: $selectionRepo)
            }
        }
        .safeAreaInset(edge: .bottom) {
            NoteSidebarToolView(showReposView: $showReposView, 
                                isSyncRepos: $isSyncRepos,
                                showImageBrowser: $showImageBrowser,
                                selectionRepo: $selectionRepo) { callBack in
                requestAllRepo(false) {
                    callBack()
                }
            }
        }
    }
}

extension NoteSidebarView {
    
    private func requestAllRepo(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        
        if readCache {
            CacheManager.fetchRepos { list in
                "#request# Repo all cache \(list.count)".logI()
                reposGroups = list
                if let repo = list.first(where: {$0.name == Account.repo}) {
                    selectionRepo = repo
                }
                completion()
            }
            return
        }
        
        repoPage = 1
        let allRepos: [RepoModel] = []
        requestRepo(repoPage, allRepos, readCache, true) { netList, success, more in
            "#request# Repo all \(netList.count)".logI()
            CacheManager.insertRepos(repos: netList) {
                CacheManager.fetchRepos { list in
                    reposGroups = list
                    completion()
                }
            }
        }
    }
    
    private func requestRepo(_ page: Int, _ repos: [RepoModel], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[RepoModel]>) -> Void {
        
        var repos = repos
        
        "#request# Repo start page \(page) readCache \(readCache) next \(next)".logI()
        
        Networking<RepoModel>().request(API.repos(page: page), readCache: readCache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            
            guard let list = data else {
                "#request# Repo page \(page) error".logE()
                completion(repos, false, false)
                return
            }
            
            "#request# Repo page \(page) \(list.count)".logI()
            
            if page <= 1 {
                if let owner = list.first?.fullName?.split(separator: "/").first {
                    "#repo# owner \(owner) - \(Account.owner)".logI()
                    if owner != Account.owner {
                        ToastManager.shared.showFail("owner error")
                    }
                }
            }
            if let repo = list.first(where: {$0.name == Account.repo}) {
                selectionRepo = repo
            }
            
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
        
        if readCache {
            CacheManager.fetchIssues { list in
                "#request# issue all cache \(list.count)".logI()
                issueGroups = list
                selectionIssue = list.first
                CacheManager.shared.currentIssue = selectionIssue
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
        
        Networking<Issue>().request(API.repoIssues(repoName: repoName, page: page), readCache: readCache,
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
        
        Networking<Comment>().request(API.comments(issueId: number, page: commentPage), readCache: readCache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
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
