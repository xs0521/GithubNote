//
//  NoteCommentsHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteCommentsHeaderView: View {
    
    @Binding var selectionIssue: Issue?
    
    @State var isCommentRefreshing: Bool = false
    @State private var isNewCommentSending: Bool = false
    
    var refreshCallBack: CommonTCallBack<CommonCallBack>?
    var createCallBack: ((_ comment: Comment, _ callBack: @escaping CommonCallBack) ->())?
    
    
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
    //                    commentsData(false) {}
                        isCommentRefreshing = true
                        refreshCallBack?({
                            isCommentRefreshing = false
                        })
                        
                    } label: {
                        
                        Image(systemName: AppConst.downloadIcon)
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
                        createComment(selectionIssue)
                    } label: {
                        Image(systemName: AppConst.plusIcon)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 20, height: 30)
                }
            }
            .padding(.trailing, 12)
        }
    }
}

extension NoteCommentsHeaderView {
    
    func createComment(_ issue: Issue?) -> Void {
        guard let issueId = issue?.number else { return }
        let body = AppConst.markdown
        isNewCommentSending = true
        Networking<Comment>().request(API.newComment(issueId: issueId, body: body), writeCache: false, readCache: false, parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
            guard let comment = data?.first else {
                isNewCommentSending = false
                return
            }
            createCallBack?(comment, {
                isNewCommentSending = false
            })
        }
    }
}

//#Preview {
//    NoteCommentsHeaderView()
//}
