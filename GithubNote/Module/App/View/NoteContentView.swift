//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI

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
    @State private var importing: Bool? = false
    
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
                                importing: $importing, 
                                issueSyncCallBack: { callBack in
                    requestIssue(false, callBack)
                })
              
            } detail: {
                NoteWritePannelView(commentGroups: $allComment,
                                          comment: $selectionComment,
                                            issue: $selectionIssue,
                                        importing: $importing)
                .background(Color.white)
            }
            .onAppear(perform: {
                requestRepo {}
            })
            .onChange(of: selectionRepo) { oldValue, newValue in
                if oldValue != newValue {
                    guard let repoName = newValue?.name else { return }
                    UserDefaults.save(value: repoName, key: AccountType.repo.key)
                    requestIssue {}
                }
            }
            if importing! {
                NoteImageBrowserView(showImageBrowser: $importing)
            }
        }
    }
    
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
