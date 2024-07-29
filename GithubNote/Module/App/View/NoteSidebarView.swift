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
    
    @Binding var showImageBrowser: Bool?
    
    @State var showReposView: Bool = false
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
                                        deleteComment(selection)
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
                                        closeIssue(selection)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            if showReposView {
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
            HStack {
                Button(action: {
                    showReposView = !showReposView
                }, label: {
                    Label("Repos", systemImage: "chevron.right")
                        .foregroundStyle(Color.primary)
                })
                .buttonStyle(.borderless)
                .foregroundColor(.accentColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
        .onChange(of: selectionRepo) { oldValue, newValue in
            if oldValue != newValue {
                guard let repoName = newValue?.name else { return }
                UserDefaults.save(value: repoName, key: AccountType.repo.key)
                showReposView = false
            }
        }
        .onChange(of: selectionIssue) { oldValue, newValue in
            if oldValue != newValue {
                commentsData {}
            }
        }
    }
    
    
}

extension NoteSidebarView {
    
    private func commentsData(_ cache: Bool = true, _ complete: @escaping () -> Void) -> Void {
        guard let number = selectionIssue?.number else { return }
        Networking<Comment>().request(API.comments(issueId: number), readCache: cache, parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
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
    
    private func createIssue() -> Void {
        isNewIssueSending = true
        let title = AppConst.issueMarkdown
        let body = AppConst.issueBodyMarkdown
        Networking<Issue>().request(API.newIssue(title: title, body: body), writeCache: false, readCache: false) { data, cache, _ in
            guard let issue = data?.first else {
                isNewIssueSending = false
                return
            }
            issueGroups.insert(issue, at: 0)
            selectionIssue = issue
            isNewIssueSending = false
        }
    }
    
    private func closeIssue(_ issue: Issue) -> Void {
        guard let issueId = issue.number, let title = issue.title, let body = issue.body, let repoName = selectionRepo?.name else { return }
        Networking<Issue>().request(API.updateIssue(issueId: issueId, state: .closed, title: title, body: body), writeCache: false, readCache: false) { data, cache, _ in
            if data != nil {
                issueGroups.removeAll(where: {$0.number == issueId})
                CacheManager.shared.updateIssues(issueGroups, repoName: repoName)
            }
        }
    }
    
    private func createComment(_ issue: Issue?) -> Void {
        guard let issueId = issue?.number else { return }
        let body = AppConst.markdown
        isNewCommentSending = true
        Networking<Comment>().request(API.newComment(issueId: issueId, body: body), writeCache: false, readCache: false) { data, cache, _ in
            guard let comment = data?.first else {
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
    
    private func deleteComment(_ comment: Comment) -> Void {
        guard let commentId = comment.id, let issueId = selectionIssue?.number else { return }
        Networking<Comment>().request(API.deleteComment(commentId: commentId)) { data, cache, code in
            if MessageCode.finish.rawValue != code {
                return
            }
            commentGroups.removeAll(where: {$0.id == commentId})
            CacheManager.shared.updateComments(commentGroups, issueId: issueId)
        }
    }
}