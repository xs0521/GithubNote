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
    
    var body: some View {
        ZStack {
            VStack {
                NoteCommentsHeaderView(selectionIssue: $selectionIssue) {
                    commentsData(false) {}
                } createCallBack: { comment, finishCallBack in
                    commentsData(false) {
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
                }) { callBack in
                    requestIssue(false) {
                        
                    }
                }
                NoteIssuesView(issueGroups: $issueGroups,
                               selectionIssue: $selectionIssue,
                               selectionRepo: $selectionRepo,
                               showReposView: $showReposView) {
                    commentsData {}
                }
            }
            .onChange(of: selectionRepo) { oldValue, newValue in
                if oldValue != newValue {
                    requestIssue {}
                }
            }
            .onAppear {
                requestAllRepo { }
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
                            requestAllRepo {
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
    
    private func requestAllRepo(_ completion: CommonCallBack) -> Void {
        repoPage = 1
        requestRepo(repoPage, false, true) { success, more in }
    }
    
    private func requestRepo(_ page: Int, _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack) -> Void {
        Networking<RepoModel>().request(API.repos(page: page), readCache: readCache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            
            guard let list = data else {
                completion(false, false)
                return
            }
            
            if page <= 1 {
                if let owner = list.first?.fullName?.split(separator: "/").first {
                    "#repo# owner \(owner) - \(Account.owner)".logI()
                    if owner != Account.owner {
                        ToastManager.shared.showFail("owner error")
                    }
                }
                reposGroups.removeAll()
            }
            
            reposGroups.append(contentsOf: list)
            if let repo = reposGroups.first(where: {$0.name == Account.repo}) {
                selectionRepo = repo
            } else {
                if let firstRepo = reposGroups.first {
                    selectionRepo = firstRepo
                }
            }
            
            if next {
                if list.isEmpty {
                    completion(true, false)
                } else {
                    repoPage += 1
                    requestRepo(repoPage, false, next, completion)
                }
            } else {
                completion(true, !list.isEmpty)
            }
        }
    }
    
    private func requestIssue(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
        guard let repoName = selectionRepo?.name else { return }
        Networking<Issue>().request(API.repoIssues(repoName: repoName, page: issuePage), readCache: readCache,
                                    parseHandler: ModelGenerator(snakeCase: true, filter: true)) { (data, _, _) in
            guard let list = data, !list.isEmpty else {
                issueGroups.removeAll()
                return
            }
            issueGroups = list
            completion()
        }
    }
    
    private func commentsData(_ cache: Bool = true, _ complete: @escaping () -> Void) -> Void {
        guard let number = selectionIssue?.number else { return }
        Networking<Comment>().request(API.comments(issueId: number, page: commentPage), readCache: cache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            guard let list = data, !list.isEmpty else {
                commentGroups.removeAll()
                return
            }
            commentGroups.removeAll()
            commentGroups = list
            let item = commentGroups.first(where: {$0.id == selectionComment?.id})
            selectionComment = item
            complete()
        }
    }
}
