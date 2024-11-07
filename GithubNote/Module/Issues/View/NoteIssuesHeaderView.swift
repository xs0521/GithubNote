//
//  NoteIssuesHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteIssuesHeaderView: View {
    
    @State private var isNewIssueSending: Bool = false
    @State private var isIssueRefreshing: Bool = false
    
    var body: some View {
        HStack {
            Text("NoteBook")
                .padding(.leading, 16)
            Spacer()
            HStack {
                if isIssueRefreshing {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 30)
                } else {
                    Button {
                        isIssueRefreshing = true
                        store.dispatch(action: IssuesActions.FetchList(readCache: false, completion: { finish in
                            isIssueRefreshing = false
                        }))
                    } label: {
                        CustomImage(systemName: AppConst.downloadIcon)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 5)
                }
                if isNewIssueSending {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 30)
                } else {
                    Button {
                        isNewIssueSending = true
                        store.dispatch(action: IssuesActions.Create(completion: { finish in
                            store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _ in
                                isNewIssueSending = false
                            }))
                        }))
                    } label: {
                        CustomImage(systemName: AppConst.plusIcon)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 20, height: 30)
                }
            }
            .frame(width: 40, height: 40)
            .padding(.trailing, 12)
        }
    }
    
    
}

//#Preview {
//    NoteIssuesHeaderView()
//}
