//
//  NoteCommentsView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteCommentsView: View {
    
    @Binding var commentGroups: [Comment]
    @Binding var selectionComment: Comment?
    @Binding var selectionIssue: Issue?
    
    @State var deleteComment: Comment?
    
    var body: some View {
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
                            if deleteComment?.id == selection.id {
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
                                deleteComment = selection
                                deleteComment(selection)
                            }
                        }
                    }
                    .frame(height: AppConst.sideItemHeight)
                }
            }
        }
    }
}

extension NoteCommentsView {
    
    private func deleteComment(_ comment: Comment) -> Void {
        guard let commentId = comment.id else { return }
        Networking<Comment>().request(API.deleteComment(commentId: commentId)) { data, cache, code in
            if MessageCode.finish.rawValue != code {
                return
            }
            commentGroups.removeAll(where: {$0.id == commentId})
            CacheManager.deleteComment([commentId]) { }
        }
    }
}

//#Preview {
//    NoteCommentsView()
//}
