//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by luoshuai on 2024/7/9.
//

import SwiftUI

struct NoteSidebarView: View {
    
    @Binding var userCreatedGroups: [Repo]
    
    @Binding var reposGroups: [Repo]
    @Binding var selection: Repo?
    
    @Binding var issueGroups: [Issue]
    @Binding var selectionIssue: Issue?
    
    @Binding var commentGroups: [Comment]
    @Binding var selectionComment: Comment?
    
    @State var showRepos: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Comments")
                        .padding(.leading, 16)
                    Spacer()
                }
                List(selection: $selectionComment) {
                    ForEach(commentGroups) { selection in
                        Label(selection.value.toTitle(),
                              systemImage: "star")
                        .tag(selection)
                    }
                }
                Spacer()
                HStack {
                    Text("Issues")
                        .padding(.leading, 16)
                    Spacer()
                }
                List(selection: $selectionIssue) {
                    ForEach(issueGroups) { selection in
                        Label(selection.title ?? "unknow",
                              systemImage: "star")
                        .tag(selection)
                    }
                }
                .frame(maxHeight: 200)
            }
            if showRepos {
                List(selection: $selection) {
                    ForEach(reposGroups) { selection in
                        Label(selection.name ?? "unknow",
                              systemImage: "star")
                        .tag(selection)
                    }
                }
                .background(.white)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showRepos = !showRepos
            }, label: {
                Label("Repos", systemImage: "chevron.right")
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .keyboardShortcut(/*@START_MENU_TOKEN@*/KeyEquivalent("a")/*@END_MENU_TOKEN@*/, modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
        }
        .onChange(of: selectionIssue) { oldValue, newValue in
            if oldValue != newValue, let number = newValue?.number {
                Request.getIssueCommentsData(issuesNumber: number) { resNumber, comments in
                    DispatchQueue.main.async(execute: {
                        if resNumber != number {
                            return
                        }
                        "reload comments \(comments.count)".p()
                        commentGroups = comments
                    })
                }
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            if oldValue != newValue {
                showRepos = false
            }
        }
        
    }
}
