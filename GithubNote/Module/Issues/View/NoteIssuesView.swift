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
                                CustomImage(systemName: "menucard")
                                    .foregroundStyle(Color.primary)
                                    .padding(.leading, 3)
                                HStack {
                                    TextField("", text: $issueStore.editText)
                                        .focused($focusedField, equals: .title)
                                        .frame(height: 18)
                                        .font(.system(size: 12))
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
                                        store.dispatch(action: IssuesActions.Edit(item: editIssue, title: issueStore.editText, completion: { finish in
                                            store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _  in
                                                isEditIssueTitleSending = false
                                                focusedField = nil
                                                store.dispatch(action: IssuesActions.WillEditAction(item: nil))
                                            }))
                                        }))
                                    } label: {
                                        CustomImage(systemName: "checkmark.circle.fill")
                                    }
                                    .buttonStyle(.plain)
                                    .frame(width: 20, height: 20)
                                }
                            }
                            .frame(height: AppConst.sideItemHeight)
                        } else {
                            Label(title: {
                                Text(selection.title ?? "unknow")
                                    .font(.system(size: 12))
                            }, icon: {
                                if props.deleteIssue?.id == selection.id {
                                    ProgressView()
                                        .controlSize(.mini)
                                        .frame(width: 20, height: 20)
                                } else {
                                    CustomImage(systemName: "menucard")
                                        .foregroundStyle(Color.primary)
                                }
                            })
                            .tag(selection)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    "delete \(selection.title ?? "")".logI()
                                    store.dispatch(action: IssuesActions.WillDeleteAction(item: selection))
                                    store.dispatch(action: IssuesActions.Delete(item: selection, completion: { finish in
                                        store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _  in
                                            store.dispatch(action: IssuesActions.WillDeleteAction(item: nil))
                                        }))
                                    }))
                                }
                                Button("Edit", role: .destructive) {
                                    "edit \(selection.title ?? "")".logI()
                                    focusedField = .title
                                    issueStore.editText = selection.title ?? ""
                                    store.dispatch(action: IssuesActions.WillEditAction(item: selection))
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
    }
}

//#Preview {
//    NoteIssuesView()
//}
