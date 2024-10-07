//
//  NoteIssuesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI
import AppKit

struct NoteIssuesView: View {
    
    private enum Field: Int, Hashable {
        case title
    }
    
    @Binding var issueGroups: [Issue]
    @Binding var selectionIssue: Issue?
    @Binding var selectionRepo: RepoModel?
    @Binding var showReposView: Bool
    
    @State private var editIssue: Issue?
    @State private var editText: String = ""
    @State private var deleteIssue: Issue?
    @State private var isEditIssueTitleSending: Bool = false
    
    
    @FocusState private var focusedField: Field?
    
    var requestComments: CommonTCallBack<Issue?>?
    
    var body: some View {
        VStack {
            if issueGroups.isEmpty {
                Image(systemName: "cup.and.saucer")
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectionIssue) {
                    ForEach(issueGroups) { selection in
                        if selection == editIssue {
                            HStack {
                                Image(systemName: "menucard")
                                    .foregroundStyle(Color.primary)
                                    .padding(.leading, 3)
                                HStack {
                                    TextField("", text: $editText)
                                        .focused($focusedField, equals: .title)
                                        .frame(height: 18)
                                        .font(.system(size: 13))
                                        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                if isEditIssueTitleSending {
                                    ProgressView()
                                        .controlSize(.mini)
                                        .frame(width: 20, height: 20)
                                } else {
                                    Button {
                                        updateIssueTitle(editIssue, editText)
                                    } label: {
                                        Image(systemName: "greaterthan.circle")
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: 20, height: 20)
                                }
                            }
                        } else {
                            Label(title: {
                                Text(selection.title ?? "unknow")
                            }, icon: {
                                if deleteIssue?.id == selection.id {
                                    ProgressView()
                                        .controlSize(.mini)
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: "menucard")
                                        .foregroundStyle(Color.primary)
                                }
                            })
                            .tag(selection)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    "delete \(selection.title ?? "")".logI()
                                    deleteIssue = selection
                                    closeIssue(selection)
                                }
                                Button("Edit", role: .destructive) {
                                    "edit \(selection.title ?? "")".logI()
                                    editIssue = selection
                                    editText = editIssue?.title ?? ""
                                    focusedField = .title
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .onChange(of: selectionRepo) { oldValue, newValue in
            if oldValue != newValue {
                guard let repoName = newValue?.name else { return }
                UserDefaults.save(value: repoName, key: AccountType.repo.key)
                showReposView = false
            }
            endEdit()
        }
        .onChange(of: selectionIssue) { oldValue, newValue in
            if oldValue != newValue {
                requestComments?(newValue)
            }
            endEdit()
        }
    }
}

extension NoteIssuesView {
    
    func endEdit() -> Void {
        focusedField = nil
        editIssue = nil
    }
    
    
}

extension NoteIssuesView {
    
    func updateIssueTitle(_ issue: Issue?, _ title: String) -> Void {
        
        guard let issue = issue else { return }
        
        isEditIssueTitleSending = true
        guard let issueId = issue.number, let body = issue.body else { return }
        Networking<Issue>().request(API.updateIssue(issueId: issueId, state: .open, title: title, body: body), writeCache: false, readCache: false) { data, cache, _ in
            if data != nil {
                var issue = issue
                issue.title = title
                CacheManager.updateIssues([issue]) {
                    CacheManager.fetchIssues { localList in
                        issueGroups = localList
                        isEditIssueTitleSending = false
                        endEdit()
                    }
                }
            } else {
                ToastManager.shared.showFail("fail")
                isEditIssueTitleSending = false
                endEdit()
            }
        }
    }
    
    func closeIssue(_ issue: Issue) -> Void {
        guard let number = issue.number, let title = issue.title, let body = issue.body else { return }
        Networking<Issue>().request(API.updateIssue(issueId: number, state: .closed, title: title, body: body), writeCache: false, readCache: false) { data, cache, _ in
            if data != nil {
                guard let issueId = issue.id else { return }
                CacheManager.deleteIssue(issueId) {
                    guard let tableName = CacheManager.shared.manager?.commentTableName(issueId), let url = issue.url else {
                        return
                    }
                    CacheManager.deleteComment(url, tableName) { }
                    issueGroups.removeAll(where: {$0.id == issueId})
                    selectionIssue = issueGroups.first
                }
            } else {
                ToastManager.shared.showFail("fail")
            }
        }
    }
}

//#Preview {
//    NoteIssuesView()
//}
