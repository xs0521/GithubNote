//
//  NoteCommentsHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteCommentsHeaderView: View {
    
    @State private var isCommentRefreshing: Bool = false
    @State private var isNewCommentSending: Bool = false
    
    var body: some View {
        HStack {
            Text("Note")
                .padding(.leading, 16)
            Spacer()
            HStack {
                if isCommentRefreshing {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 30)
                } else {
                    Button {
                        isCommentRefreshing = true
                        store.dispatch(action: CommentActions.FetchList(readCache: false, showTip: true, completion: { finish in
                            isCommentRefreshing = false
                        }))
                        
                    } label: {
                        CustomImage(systemName: AppConst.downloadIcon)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 5)
                }
                if isNewCommentSending {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 30)
                } else {
                    Button {
                        isNewCommentSending = true
                        store.dispatch(action: CommentActions.Create(completion: { finish in
                            store.dispatch(action: CommentActions.FetchList(readCache: true, completion: { _ in
                                isNewCommentSending = false
                            }))
                        }))
                    } label: {
                        CustomImage(systemName: AppConst.plusIcon)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 20, height: 30)
                }
            }
            .padding(.trailing, 12)
        }
    }
}

//#Preview {
//    NoteCommentsHeaderView()
//}
