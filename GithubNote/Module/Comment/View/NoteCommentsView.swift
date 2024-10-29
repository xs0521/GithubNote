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
                NoteEmptyView()
            } else {
                List(selection: $commentStore.select) {
                    ForEach(props.list) { selection in
                        Label(title: {
                            Text(selection.body?.toTitle() ?? "")
                        }, icon: {
                            if props.deleteComment?.id == selection.id {
                                ProgressView()
                                    .controlSize(.mini)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "note")
                                    .foregroundStyle(Color.primary)
                            }
                        })
                        .tag(selection)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                "delete \(selection.body?.toTitle() ?? "")".logI()
//                                deleteComment = selection
//                                deleteComment(selection)
                            }
                        }
                    }
                    .frame(height: AppConst.sideItemHeight)
                }
            }
        }
        .onAppear {
            commentStore.listener.loadPage()
        }
    }
}

extension NoteCommentsView {
    
//    private func deleteComment(_ comment: Comment) -> Void {
//        guard let commentId = comment.id else { return }
//        Networking<Comment>().request(API.deleteComment(commentId: commentId)) { data, cache, code in
//            if MessageCode.finish.rawValue != code {
//                return
//            }
//            commentGroups.removeAll(where: {$0.id == commentId})
//            CacheManager.deleteComment([commentId]) { }
//        }
//    }
}

//#Preview {
//    NoteCommentsView()
//}
