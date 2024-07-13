//
//  NoteContentView.swift
//  GithubNote
//
//  Created by luoshuai on 2024/7/9.
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
    
    @State private var currentComments = [Comment]()
    @State private var currentSelectionComment: Comment?
    
    var body: some View {
        NavigationSplitView {
            NoteSidebarView(userCreatedGroups: $userCreatedGroups,
                            reposGroups: $allRepo,
                            selection: $selection,
                            issueGroups: $allIssue,
                            selectionIssue: $selectionIssue,
                            commentGroups: $currentComments,
                            selectionComment: $currentSelectionComment)
          
        } detail: {
            NoteTaskListView(title: "All", tasks: $allComment)
        }
        .onAppear(perform: {
            Request.getReposData { repos in
                allRepo = repos
                guard let repo = repos.first else {
                    return
                }
                selection = repo
            }
        })
        .onChange(of: selection) { oldValue, newValue in
            if oldValue != newValue {
                guard let repoName = newValue?.name else { return }
                Request.getRepoIssueData(repoName) { list in
                    DispatchQueue.main.async(execute: {
                        allIssue = list
                    })
                }
            }
        }
//        .onChange(of: selectionIssue) { oldValue, newValue in
//            if oldValue != newValue, let number = newValue?.number {
//                Request.getIssueCommentsData(issuesNumber: number) { resNumber, comments in
//                    DispatchQueue.main.async(execute: {
//                        if resNumber != number {
//                            return
//                        }
//                        "reload comments \(comments.count)".p()
//                        allComment = comments
//                    })
//                }
//            }
//        }
    }
}
