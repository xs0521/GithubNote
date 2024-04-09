//
//  CommentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation
import SwiftUI
import Combine

struct CommentView: View {
    
    @Binding var model: CommentModel
    @Binding var selectedSideBarItem: Issue
    
    @State private var isCommentloading: Bool = true
    @State private var commentHeight: CGFloat = AppConst.commentItemHeight * 2
    
    @State private var issuesNumber: Int?
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                List(model.commentList, id: \.id) { item in
                    Text(item.value.toTitle())
                    .frame(height: AppConst.commentItemHeight)
                    .foregroundStyle(item.commentid == model.selectedCommentItem?.commentid ? Color.black : Color.gray)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .onTapGesture {
                        model.selectedCommentItem = item
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .listRowInsets(EdgeInsets())
                .frame(maxHeight: commentHeight, alignment: .leading)
                Spacer()
            }
            if model.commentList.isEmpty && !isCommentloading {
                Image(systemName: EmptyModel.figureArray.randomElement() ?? "")
                    .font(.system(size: 30))
            }
            if isCommentloading {
                ProgressView()
                    .padding(.bottom, 60)
            }
            if let _ = selectedSideBarItem.id {
                VStack {
                    Spacer()
                    Button {
                        guard let issuesNumber = selectedSideBarItem.number else { return }
                    Request.createComment(issuesNumber: issuesNumber, content: AppConst.markdown, completion: { comment in
                        if let comment = comment {
                            DispatchQueue.main.async(execute: {
                                model.commentList.append(comment)
                                commentHeight = CGFloat(model.commentList.count) * AppConst.commentItemHeight
                                "add comment \(model.commentList.count)".p()
                            })
                        }
                    })
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 20)
                }
            }
        }
        .onChange(of: selectedSideBarItem) { newValue in
            "comment issue change \(newValue.number ?? 0)".p()
            if issuesNumber != newValue.number {
                issuesNumber = newValue.number
                reloadComments()
            }
        }
        
    }
    
    func reloadComments() -> Void {
        if let number = selectedSideBarItem.number {
            isCommentloading = true
            Request.getIssueCommentsData(issuesNumber: number) { resNumber, comments in
                DispatchQueue.main.async(execute: {
                    isCommentloading = false
                    if resNumber != number {
                        return
                    }
                    "reload comments \(comments.count)".p()
                    model.commentList = comments
                    commentHeight = CGFloat(comments.count) * AppConst.commentItemHeight
                })
            }
        } else {
            model.commentList.removeAll()
            commentHeight = AppConst.commentItemHeight * 2
        }
    }
}
