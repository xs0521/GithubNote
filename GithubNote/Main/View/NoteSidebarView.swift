//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI

struct NoteSidebarView: View {
    
    @Binding var userCreatedGroups: [Repo]
    
    @Binding var reposGroups: [Repo]
    @Binding var selectionRepo: Repo?
    
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
                    Button {
                        createComment(selectionIssue)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 12)
                }
                List(selection: $selectionComment) {
                    ForEach(commentGroups) { selection in
                        Label(selection.body.toTitle(),
                              systemImage: "star")
                        .tag(selection)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                "delete \(selection.body.toTitle())".p()
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Text("Issues")
                        .padding(.leading, 16)
                    Spacer()
                    Button {
                        createIssue(selectionRepo)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 12)

                }
                List(selection: $selectionIssue) {
                    ForEach(issueGroups) { selection in
                        Label(selection.title ?? "unknow",
                              systemImage: "star")
                        .tag(selection)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                "delete \(selection.title ?? "")".p()
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            if showRepos {
                List(selection: $selectionRepo) {
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
        }
        .onChange(of: selectionRepo) { oldValue, newValue in
            if oldValue != newValue {
                showRepos = false
            }
        }
        .onChange(of: selectionIssue) { oldValue, newValue in
            if oldValue != newValue {
                commentsData {}
            }
        }
    }
    
    func commentsData(_ complete: () -> Void) -> Void {
        guard let number = selectionIssue?.number else { return }
        Request.getIssueCommentsDataV2(issuesNumber: number) { resNumber, comments in
            DispatchQueue.main.async(execute: {
                if resNumber != number {
                    return
                }
                "reload comments \(comments.count)".p()
                commentGroups = comments
            })
        }
    }
    
    func createIssue(_ repo: Repo?) -> Void {
        
    }
    
    func createComment(_ issue: Issue?) -> Void {
        guard let issue = issue, let number = issue.number else { return }
        Request.createComment(issuesNumber: number, content: AppConst.markdown, completion: { comment in
            if let comment = comment {
                commentsData {
                    let select = commentGroups.first(where: {$0.commentid == comment.commentid})
                    DispatchQueue.main.async(execute: {
                        selectionComment = select
                    })
                }
            }
        })
    }
}
