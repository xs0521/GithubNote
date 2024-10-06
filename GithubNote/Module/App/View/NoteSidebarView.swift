//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AppKit

struct NoteSidebarView: View {
    
    @Binding var userCreatedGroups: [RepoModel]
    
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
                NoteCommentsHeaderView(selectionIssue: $selectionIssue) {
                    requestAllComment(false) { }
                } createCallBack: { comment, finishCallBack in
                    requestAllComment(false) {
                        let select = commentGroups.first(where: {$0.id == comment.id})
                        DispatchQueue.main.async(execute: {
                            selectionComment = select
                            finishCallBack()
                        })
                    }
                }
                NoteCommentsView(commentGroups: $commentGroups,
                                 selectionComment: $selectionComment,
                                 selectionIssue: $selectionIssue)
                Spacer()
                NoteIssuesHeaderView(createIssueCallBack: { issue in
                    issueGroups.insert(issue, at: 0)
                    selectionIssue = issue
                    requestAllComment {}
                }) { callBack in
                    requestAllIssue(false) {}
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
            HStack {
                Button(action: {
                    showReposView = !showReposView
                }, label: {
                    Label("Repos", systemImage: "chevron.right")
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                })
                .buttonStyle(.borderless)
                .foregroundColor(.accentColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if showReposView {
                    if isSyncRepos {
                        ProgressView()
                            .controlSize(.mini)
                            .padding()
                            .padding(.trailing, 5)
                    } else {
                        Button {
                            isSyncRepos = true
                            requestAllRepo(false) {
                                isSyncRepos = false
                            }
                        } label: {
                            Image(systemName: "icloud.and.arrow.down")
                        }
                        .buttonStyle(.plain)
                        .padding()
                    }
                } else {
                    Button(action: {
                        showImageBrowser?.toggle()
                    }, label: {
                        Image(systemName: "photo.on.rectangle.angled")
                    })
                    .buttonStyle(.plain)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
        requestRepo(repoPage, allRepos, readCache, true) { list, success, more in
            "#request# Repo all \(list.count)".logI()
            reposGroups = list
            CacheManager.insertRepos(repos: list)
            completion()
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
    
    private func requestAllIssue(_ readCache: Bool = true, _ completion: CommonCallBack) -> Void {
        
        if readCache {
            CacheManager.fetchIssues { list in
                "#request# issue all cache \(list.count)".logI()
                issueGroups = list
                selectionIssue = list.first
                CacheManager.shared.currentIssue = selectionIssue
            }
            return
        }
        
        issuePage = 1
        let allIssue: [Issue] = []
        requestIssue(issuePage, allIssue, false, true) { list, success, more in
            "#request# issue all \(list.count)".logI()
            issueGroups = list
            CacheManager.insertIssues(issues: list)
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
    
    private func requestAllComment(_ readCache: Bool = true, _ completion: CommonCallBack) -> Void {
        
        if readCache {
            CacheManager.fetchComments { list in
                "#request# comment all cache \(list.count)".logI()
                commentGroups = list
                selectionComment = list.first
            }
            return
        }
        
        commentPage = 1
        let allComment: [Comment] = []
        commentsData(commentPage, allComment, readCache, true) { list, success, more in
            "#request# comment all \(list.count)".logI()
            commentGroups = list
            CacheManager.insertComments(comments: list)
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
