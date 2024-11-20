//
//  NoteCommentsView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI
import SwiftUIFlux

struct NoteCommentsView: ConnectedView {
    
    @EnvironmentObject var issueStore: IssueModelStore
    @EnvironmentObject var commentStore: CommentModelStore
    
    @State private var isTapEmptyLoading: Bool = false
    @State private var isLoaded: Bool = false
    
    struct Props {
        let editComment: Comment?
        let deleteComment: Comment?
        let list: [Comment]
        let selectionIssue: Issue?
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(editComment: state.commentStates.editItem,
                     deleteComment: state.commentStates.deleteItem,
                     list: state.commentStates.items,
                     selectionIssue: issueStore.select)
    }
    
    func body(props: Props) -> some View {
        VStack {
            if props.list.isEmpty {
                if isTapEmptyLoading {
                    ZStack {
                        ProgressView()
                            .controlSize(.mini)
                            .frame(width: 25, height: 25)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    NoteEmptyView(tapCallBack: {
                        isTapEmptyLoading = true
                        store.dispatch(action: CommentActions.FetchList(readCache: false, showTip: true, completion: { finish in
                            isTapEmptyLoading = false
                        }))
                    })
                }
            } else {
                List(selection: $commentStore.select) {
                    ForEach(props.list) { selection in
                        Label(title: {
                            Text(selection.body?.toTitle() ?? "")
                                .font(.system(size: 12))
                        }, icon: {
                            if props.deleteComment?.id == selection.id {
                                ProgressView()
                                    .controlSize(.mini)
                                    .frame(width: 20, height: 20)
                            } else {
                                CustomImage(systemName: "note")
                                    .foregroundStyle(Color.primary)
                            }
                        })
                        .tag(selection)
                        .contextMenu {
                            Button("delete".language(), role: .destructive) {
                                "delete \(selection.body?.toTitle() ?? "")".logI()
                                store.dispatch(action: CommentActions.WillDeleteAction(item: selection))
                                store.dispatch(action: CommentActions.Delete(item: selection, completion: { finish in
                                    store.dispatch(action: CommentActions.FetchList(readCache: true, completion: { _  in
                                        store.dispatch(action: CommentActions.WillDeleteAction(item: nil))
                                    }))
                                }))
                            }
                        }
                    }
                    .frame(height: AppConst.sideItemHeight)
                }
            }
        }
        .onAppear {
            if !isLoaded {
                commentStore.listener.loadPage()
                isLoaded = true
            }
            
        }
    }
}

//#Preview {
//    NoteCommentsView()
//}
