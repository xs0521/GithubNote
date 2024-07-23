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
    
    @Binding var reposGroups: [RepoModel]
    @Binding var selectionRepo: RepoModel?
    
    @Binding var issueGroups: [Issue]
    @Binding var selectionIssue: Issue?
    
    @Binding var commentGroups: [Comment]
    @Binding var selectionComment: Comment?
    
    @Binding var importing: Bool?
    
    @State var showRepos: Bool = false
    @State var isNewIssueSending: Bool = false
    @State var isNewCommentSending: Bool = false
    
    var issueSyncCallBack: (_ callBack: @escaping CommonCallBack) -> ()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Note")
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button {
                            commentsData(false) {}
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 5)
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
                                    Text(selection.body?.toTitle() ?? "")
                                }, icon: {
                                    Image(systemName: "note.text")
                                        .foregroundStyle(Color.primary)
                                })
                                .tag(selection)
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        "delete \(selection.body?.toTitle() ?? "")".p()
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
                    HStack {
                        Button {
                            issueSyncCallBack({})
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 5)
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
    
    func commentsData(_ cache: Bool = true, _ complete: @escaping () -> Void) -> Void {
        guard let number = selectionIssue?.number else { return }
        Networking<Comment>().request(API.comments(issueId: number), readCache: cache, parseHandler: ModelGenerator(convertFromSnakeCase: true)) { (data, _) in
            guard let list = data, !list.isEmpty else {
                commentGroups.removeAll()
                return
            }
            commentGroups = list
            complete()
        }
    }
    
    func createIssue() -> Void {
        isNewIssueSending = true
        let title = AppConst.issueMarkdown
        let body = AppConst.issueBodyMarkdown
        Networking<Issue>().request(API.newIssue(title: title, body: body), writeCache: false, readCache: false, completionListHandler: nil) { data, cache in
            guard let _ = data else {
                isNewIssueSending = false
                return
            }
            issueSyncCallBack({
                isNewIssueSending = false
            })
        }
    }
    
    func createComment(_ issue: Issue?) -> Void {
        guard let issueId = issue?.number else { return }
        let body = AppConst.markdown
        isNewCommentSending = true
        Networking<Comment>().request(API.newComment(issueId: issueId, body: body), writeCache: false, readCache: false, completionListHandler: nil) { comment, cache in
            guard let comment = comment else {
                isNewCommentSending = false
                return
            }
            commentsData(false) {
                let select = commentGroups.first(where: {$0.id == comment.id})
                DispatchQueue.main.async(execute: {
                    selectionComment = select
                    isNewCommentSending = false
                })
            }
        }
    }
}
