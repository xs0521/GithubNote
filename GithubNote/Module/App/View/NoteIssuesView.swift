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
                                Image(systemName: "menucard")
                                    .foregroundStyle(Color.primary)
                            })
                            .tag(selection)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    "delete \(selection.title ?? "")".logI()
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
        guard let issueId = issue.number, let body = issue.body, let repoName = selectionRepo?.name else { return }
        Networking<Issue>().request(API.updateIssue(issueId: issueId, state: .open, title: title, body: body), writeCache: false, readCache: false) { data, cache, _ in
            isEditIssueTitleSending = false
            
            if data != nil {
                guard let index = issueGroups.firstIndex(where: {$0 == issue}) else {
                    return
                }
                var issue = issue
                issue.defultModel()
                issue.title = title
                var list = issueGroups
                list[index] = issue
                issueGroups = list
                CacheManager.shared.updateIssues(issueGroups, repoName: repoName)
                endEdit()
            }
        }
    }
    
    func closeIssue(_ issue: Issue) -> Void {
        guard let issueId = issue.number, let title = issue.title, let body = issue.body, let repoName = selectionRepo?.name else { return }
        Networking<Issue>().request(API.updateIssue(issueId: issueId, state: .closed, title: title, body: body), writeCache: false, readCache: false) { data, cache, _ in
            if data != nil {
                issueGroups.removeAll(where: {$0.number == issueId})
                CacheManager.shared.updateIssues(issueGroups, repoName: repoName)
            }
        }
    }
}

//#Preview {
//    NoteIssuesView()
//}
