//
//  NoteIssuesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI
import SwiftUIFlux

#if MOBILE
import UIKit
#else
import AppKit
#endif


struct NoteIssuesView: ConnectedView {
    
    @EnvironmentObject var issueStore: IssueModelStore
    
    private enum Field: Int, Hashable {
        case title
    }
    
    struct Props {
        let editIssue: Issue?
        let deleteIssue: Issue?
        let issueGroups: [Issue]
        let selectionRepo: RepoModel?
        let showReposView: Bool = false
    }
    
    @State private var isEditIssueTitleSending: Bool = false
    @FocusState private var focusedField: Field?
    
    var requestComments: CommonTCallBack<Issue?>?
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(editIssue: state.issuesStates.editItem,
                     deleteIssue: state.issuesStates.deleteItem,
                     issueGroups: state.issuesStates.items,
                     selectionRepo: state.sideStates.selectionRepo)
    }
    
    func body(props: Props) -> some View {
        VStack {
            if props.issueGroups.isEmpty {
                NoteEmptyView()
            } else {
                List(selection: $issueStore.select) {
                    ForEach(props.issueGroups) { selection in
                        if selection == props.editIssue {
                            HStack {
                                Image(systemName: "menucard")
                                    .foregroundStyle(Color.primary)
                                    .padding(.leading, 3)
                                HStack {
                                    TextField("", text: $issueStore.editText)
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
                                        guard let editIssue = props.editIssue else { return }
                                        isEditIssueTitleSending = true
                                        store.dispatch(action: IssuesActions.Edit(issue: editIssue, title: issueStore.editText, completion: { finish in
                                            store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _  in
                                                isEditIssueTitleSending = false
                                                focusedField = nil
                                                store.dispatch(action: IssuesActions.WillEditAction(issue: nil))
                                            }))
                                        }))
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: 20, height: 20)
                                }
                            }
                            .frame(height: AppConst.sideItemHeight)
                        } else {
                            Label(title: {
                                Text(selection.title ?? "unknow")
                            }, icon: {
                                if props.deleteIssue?.id == selection.id {
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
                                    store.dispatch(action: IssuesActions.WillDeleteAction(issue: selection))
                                    store.dispatch(action: IssuesActions.Delete(issue: selection, completion: { finish in
                                        store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _  in
                                            store.dispatch(action: IssuesActions.WillDeleteAction(issue: nil))
                                        }))
                                    }))
                                }
                                Button("Edit", role: .destructive) {
                                    "edit \(selection.title ?? "")".logI()
                                    focusedField = .title
                                    issueStore.editText = selection.title ?? ""
                                    store.dispatch(action: IssuesActions.WillEditAction(issue: selection))
                                }
                            }
                            .frame(height: AppConst.sideItemHeight)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .onAppear {
            issueStore.listener.loadPage()
        }
//        .onChange(of: selectionRepo) { oldValue, newValue in
//            if oldValue != newValue {
//                guard let repoName = newValue?.name else { return }
////                AppUserDefaults.repo = repoName
////                showReposView = false
//                store.dispatch(action: SideActions.ReposViewState(visible: false))
//            }
//            endEdit()
//        }
//        .onChange(of: selectionIssue) { oldValue, newValue in
//            if oldValue != newValue {
//                requestComments?(newValue)
//            }
//            endEdit()
//        }
    }
}

extension NoteIssuesView {
    
//    func updateIssueTitle(_ issue: Issue?, _ title: String) -> Void {
//        
//        guard let issue = issue else { return }
//        
//        "#issue# update title \(title)".logI()
//        
//        isEditIssueTitleSending = true
//        let body = issue.body ?? ""
//        guard let issueId = issue.number else { return }
//        Networking<Issue>().request(API.updateIssue(issueId: issueId, state: .open, title: title, body: body)) { data, cache, _ in
//            if data != nil {
//                "#issue# update success".logI()
//                var issue = issue
//                issue.title = title
//                CacheManager.updateIssues([issue]) {
//                    CacheManager.fetchIssues { localList in
//                        issueGroups = localList
//                        isEditIssueTitleSending = false
//                        endEdit()
//                    }
//                }
//            } else {
//                "#issue# update fail".logI()
//                ToastManager.shared.showFail("fail")
//                isEditIssueTitleSending = false
//                endEdit()
//            }
//        }
//    }
    
//    func closeIssue(_ issue: Issue) -> Void {
//        guard let number = issue.number, let title = issue.title, let body = issue.body else { return }
//        Networking<Issue>().request(API.updateIssue(issueId: number, state: .closed, title: title, body: body)) { data, cache, _ in
//            if data != nil {
//                guard let issueId = issue.id else { return }
//                CacheManager.deleteIssue([issueId]) {
//                    guard let tableName = CacheManager.shared.manager?.commentTableName(issueId), let url = issue.url else {
//                        return
//                    }
//                    CacheManager.deleteComment(url, tableName) { }
//                    issueGroups.removeAll(where: {$0.id == issueId})
//                    selectionIssue = issueGroups.first
//                }
//            } else {
//                ToastManager.shared.showFail("fail")
//            }
//        }
//    }
}

//#Preview {
//    NoteIssuesView()
//}
