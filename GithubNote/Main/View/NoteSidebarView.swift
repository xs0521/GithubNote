//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AppKit

struct NoteSidebarView: View {
    
    @Binding var userCreatedGroups: [Repo]
    
    @Binding var reposGroups: [Repo]
    @Binding var selectionRepo: Repo?
    
    @Binding var issueGroups: [Issue]
    @Binding var selectionIssue: Issue?
    
    @Binding var commentGroups: [Comment]
    @Binding var selectionComment: Comment?
    
    @State var showRepos: Bool = false
    @State var isNewIssueSending: Bool = false
    @State var isNewCommentSending: Bool = false
    
    var addIssueCallBack: (_ callBack: @escaping CommonCallBack) -> ()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Note")
                        .padding(.leading, 16)
                    Spacer()
                    VStack {
                        if isNewCommentSending {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Button {
                                createComment(selectionIssue)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.trailing, 12)
                }
                VStack {
                    if commentGroups.isEmpty {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 25))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(selection: $selectionComment) {
                            ForEach(commentGroups) { selection in
                                Label(title: {
                                    Text(selection.body.toTitle())
                                }, icon: {
                                    Image(systemName: "note.text")
                                        .foregroundStyle(Color.primary)
                                })
                                .tag(selection)
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        "delete \(selection.body.toTitle())".p()
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Text("NoteBook")
                        .padding(.leading, 16)
                    Spacer()
                    VStack {
                        if isNewIssueSending {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Button {
                                createIssue()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 12)

                }
                VStack {
                    if issueGroups.isEmpty {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 25))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(selection: $selectionIssue) {
                            ForEach(issueGroups) { selection in
                                Label(title: {
                                    Text(selection.title ?? "unknow")
                                }, icon: {
                                    Image(systemName: "menucard")
                                        .foregroundStyle(Color.primary)
                                })
                                .tag(selection)
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        "delete \(selection.title ?? "")".p()
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            if showRepos {
                List(selection: $selectionRepo) {
                    ForEach(reposGroups) { selection in
                        Label(title: {
                            Text(selection.name ?? "unknow")
                        }, icon: {
                            Image(systemName: "star")
                                .foregroundStyle(Color.primary)
                        })
                        .tag(selection)
                    }
                }
                .background(Color.background)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showRepos = !showRepos
            }, label: {
                Label("Repos", systemImage: "chevron.right")
                    .foregroundStyle(Color.primary)
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
    
    func commentsData(_ complete: @escaping () -> Void) -> Void {
        guard let number = selectionIssue?.number else { return }
        Request.getIssueCommentsDataV2(issuesNumber: number) { resNumber, comments in
            DispatchQueue.main.async(execute: {
                if resNumber != number {
                    complete()
                    return
                }
                "reload comments \(comments.count)".p()
                commentGroups = comments
                complete()
            })
        }
    }
    
    func createIssue() -> Void {
        isNewIssueSending = true
        Request.createIssue(title: AppConst.issueMarkdown, body: AppConst.issueBodyMarkdown) { issue in
            guard let _ = issue else {
                isNewIssueSending = false
                return
            }
            addIssueCallBack({
                isNewIssueSending = false
            })
        }
    }
    
    func createComment(_ issue: Issue?) -> Void {
        guard let issue = issue, let number = issue.number else { return }
        isNewCommentSending = true
        Request.createComment(issuesNumber: number, content: AppConst.markdown, completion: { comment in
            if let comment = comment {
                commentsData {
                    let select = commentGroups.first(where: {$0.commentid == comment.commentid})
                    DispatchQueue.main.async(execute: {
                        selectionComment = select
                        isNewCommentSending = false
                    })
                }
            }
        })
    }
}
