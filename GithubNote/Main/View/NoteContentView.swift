//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI

struct NoteContentView: View {
    
    @State private var allRepo: [Repo] = [Repo]()
    @State private var selection: Repo?
    
    @State private var allIssue = [Issue]()
    @State private var selectionIssue: Issue?
    
    @State private var allComment = [Comment]()
    @State private var selectionComment: Comment?
    
    @State private var userCreatedGroups: [Repo] = [Repo]()
    @State private var searchTerm: String = ""
    
    @State private var markdownString: String? = ""
    
    var body: some View {
        NavigationSplitView {
            NoteSidebarView(userCreatedGroups: $userCreatedGroups,
                            reposGroups: $allRepo,
                            selection: $selection,
                            issueGroups: $allIssue,
                            selectionIssue: $selectionIssue,
                            commentGroups: $allComment,
                            selectionComment: $selectionComment)
          
        } detail: {
            NoteWritePannelView(comment: $selectionComment,
                            issue: $selectionIssue)
                .background(Color.white)
        }
        .onAppear(perform: {
            Request.getReposData { repos in
                allRepo = repos
                
                if repos.isEmpty {
                    allRepo.removeAll()
                    return
                }
                
                if let repo = allRepo.first(where: {$0.name == Account.repo}) {
                    selection = repo
                    return
                }
                
                if let firstRepo = allRepo.first {
                    selection = firstRepo
                    return
                }
            }
        })
        .onChange(of: selection) { oldValue, newValue in
            if oldValue != newValue {
                guard let repoName = newValue?.name else { return }
                UserDefaults.save(value: repoName, key: AccountType.repo.key)
                Request.getRepoIssueData(repoName) { list in
                    DispatchQueue.main.async(execute: {
                        allIssue = list
                    })
                }
            }
        }
    }
}
