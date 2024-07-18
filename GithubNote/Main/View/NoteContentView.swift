//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI

struct NoteContentView: View {
    
    @State private var allRepo: [Repo] = [Repo]()
    @State private var selectionRepo: Repo?
    
    @State private var allIssue = [Issue]()
    @State private var selectionIssue: Issue?
    
    @State private var allComment = [Comment]()
    @State private var selectionComment: Comment?
    
    @State private var userCreatedGroups: [Repo] = [Repo]()
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
                                importing: $importing) { (callBack) in
                    requestIssue(callBack)
                }
              
            } detail: {
                NoteWritePannelView(commentGroups: $allComment,
                                          comment: $selectionComment,
                                            issue: $selectionIssue,
                                        importing: $importing)
                .background(Color.white)
            }
            .onAppear(perform: {
                requestRepo()
            })
            .onChange(of: selectionRepo) { oldValue, newValue in
                if oldValue != newValue {
                    guard let repoName = newValue?.name else { return }
                    UserDefaults.save(value: repoName, key: AccountType.repo.key)
                    requestIssue {
                        
                    }
                }
            }
            if importing! {
                NoteImageBrowserView(showImageBrowser: $importing)
            }
        }
    }
    
    func requestRepo() -> Void {
        Request.getReposData { repos in
            allRepo = repos
            if repos.isEmpty {
                allRepo.removeAll()
                return
            }
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
    
    func requestIssue(_ completion: @escaping CommonCallBack) -> Void {
        guard let repoName = selectionRepo?.name else { return }
        Request.getRepoIssueData(repoName) { list in
            DispatchQueue.main.async(execute: {
                allIssue = list
                completion()
            })
        }
    }
}
