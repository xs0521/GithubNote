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
    
    @ObservedObject var viewModel = ViewModel(issuesModel: IssuesModel(), commentModel: CommentModel())
    
    var body: some View {
        HStack {
            ZStack {
                HStack (spacing: 0) {
                    IssuesView(model: $viewModel.issuesModel) {
                        viewModel.commentModel.commentList.removeAll()
                    }
                    Divider()
                        .padding(.bottom, 30)
                    CommentView(model: $viewModel.commentModel, selectedSideBarItem: $viewModel.issuesModel.selectedSideBarItem)
                }
            }
            WritePannelView(markdownString: $markdownString, commentId: $commentId, issuesNumber: $issuesNumber)
            .frame(minWidth: 600, minHeight: 400, alignment: .leading)
            .background(Color.white)
        }
        .frame(minWidth: 400, minHeight: 400, alignment: .leading)
        .background(.thinMaterial)
        .onChange(of: viewModel.issuesModel.selectedSideBarItem) { oldValue, newValue in
            "contentView issue change \(oldValue.id ?? 0) \(newValue.id ?? 0)".p()
            if oldValue.id != newValue.id {
                markdownString = ""
                commentId = 0
                issuesNumber = newValue.number ?? 0
            }
        }
        .onChange(of: viewModel.commentModel.selectedCommentItem) { oldValue, newValue in
            "contentView comment change \(oldValue?.commentid ?? 0) \(newValue?.commentid ?? 0)".p()
            if oldValue?.commentid != newValue?.commentid {
                markdownString = newValue?.value ?? ""
                commentId = newValue?.commentid ?? 0
            }
        }
    }
    
}

//#Preview {
//    ContentView()
//}
