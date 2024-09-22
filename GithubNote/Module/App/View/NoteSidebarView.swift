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
    
    @State private var isSyncRepos: Bool = false
    @State private var showReposView: Bool = false
    
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false
    
    var issueSyncCallBack: (_ callBack: @escaping CommonCallBack) -> ()
    var reposSyncCallBack: (_ callBack: @escaping RequestCallBack) -> ()
    var reposMoreCallBack: (_ callBack: @escaping RequestCallBack) -> ()
    
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
                }, issueSyncCallBack: issueSyncCallBack)
                NoteIssuesView(issueGroups: $issueGroups,
                               selectionIssue: $selectionIssue,
                               selectionRepo: $selectionRepo,
                               showReposView: $showReposView) {
                    commentsData {}
                }
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
                            reposSyncCallBack({ success, more in
                                isSyncRepos = false
                            })
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
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
    
    func loadMore() -> Void {
        reposMoreCallBack({ success, more in
            footerRefreshing = false
            noMore = !more
        })
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
}
