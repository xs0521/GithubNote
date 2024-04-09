//
//  ContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var markdownString: String = ""
    @State private var commentId: Int = 0
    @State private var issuesNumber: Int = 0
    
    @State private var issueUnfold: Bool = true
    @State private var commentUnfold: Bool = true
    @State private var isCreateIssue: Bool = false
    @State private var enbleCreateIssue: Bool = true
    
    
    @ObservedObject var viewModel = ViewModel(issuesModel: IssuesModel(), commentModel: CommentModel())
    
    var body: some View {
        HStack {
            ZStack {
                HStack (spacing: 0) {
                    ZStack {
                        IssuesView(model: $viewModel.issuesModel, isCreateIssue: $isCreateIssue, enbleCreateIssue: $enbleCreateIssue) {
                            viewModel.commentModel.commentList.removeAll()
                        }
                        .frame(width: issueUnfold ? AppConst.commentMaxWidth : AppConst.commentMinWidth)
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    issueUnfold = !issueUnfold
                                    if !issueUnfold {
                                        isCreateIssue = false
                                        enbleCreateIssue = false
                                    } else {
                                        enbleCreateIssue = true
                                    }
                                } label: {
                                    Image(systemName: issueUnfold ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 20))
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .buttonStyle(.plain)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                            }
                            Spacer()
                        }
                    }
                    Divider()
                        .padding(.bottom, 30)
                    ZStack {
                        CommentView(model: $viewModel.commentModel, selectedSideBarItem: $viewModel.issuesModel.selectedSideBarItem)
                            .frame(width: commentUnfold ? AppConst.commentMaxWidth : AppConst.commentMinWidth)
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    commentUnfold = !commentUnfold
                                } label: {
                                    Image(systemName: commentUnfold ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 20))
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .buttonStyle(.plain)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                            }
                            Spacer()
                        }
                    }
                }
                .frame(width: sideWidth(), alignment: .center)
            }
            WritePannelView(markdownString: $markdownString, commentId: $commentId, issuesNumber: $issuesNumber)
            .frame(minWidth: AppConst.editMinWidth, maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .frame(minWidth: AppConst.minWidth, minHeight: AppConst.minHeight, alignment: .leading)
        .background(.thinMaterial)
        .onChange(of: viewModel.issuesModel.selectedSideBarItem) { newValue in
            "contentView issue change \(newValue.number ?? 0)".p()
            if issuesNumber != newValue.number {
                markdownString = ""
                commentId = 0
                issuesNumber = newValue.number ?? 0
            }
        }
        .onChange(of: viewModel.commentModel.selectedCommentItem) { newValue in
            "contentView comment change \(newValue?.commentid ?? 0)".p()
            if commentId != newValue?.commentid {
                markdownString = newValue?.value ?? ""
                commentId = newValue?.commentid ?? 0
            }
        }
    }
    
    func sideWidth() -> CGFloat {
        
        if issueUnfold && commentUnfold {
            return AppConst.commentMaxWidth + AppConst.issueMaxWidth
        }
        if !issueUnfold && !commentUnfold {
            return AppConst.commentMinWidth + AppConst.issueMinWidth
        }
        
        if issueUnfold && !commentUnfold {
            return AppConst.commentMinWidth + AppConst.issueMaxWidth
        }
        
        if !issueUnfold && commentUnfold {
            return AppConst.commentMaxWidth + AppConst.issueMinWidth
        }
        
        return AppConst.commentMaxWidth + AppConst.issueMaxWidth
    }
}

//struct ContentView: View {
//    var body: some View {
//        HStack {
//            ZStack {
//                HStack (spacing: 0) {
//                    HStack {
//                        
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.blue)
//                    Divider()
//                        .padding(.bottom, 30)
//                    HStack {
//                        
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.yellow)
//                }
//            }
//            .frame(minWidth: AppConst.issueMinWidth + AppConst.commentMinWidth, maxWidth: AppConst.commentMaxWidth + AppConst.issueMaxWidth)
//            .background(Color.orange)
//            HStack {
//                
//            }
//            .frame(minWidth: AppConst.editMinWidth, maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.green)
//        }
//        .frame(minWidth: AppConst.minWidth, minHeight: AppConst.minHeight)
//        .background(.red)
//    }
//}

//#Preview {
//    ContentView()
//}
