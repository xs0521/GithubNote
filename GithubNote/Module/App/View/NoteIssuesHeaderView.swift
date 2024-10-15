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
    
    var issueSyncCallBack: (_ callBack: @escaping CommonCallBack) -> ()
    var createIssueCallBack: (_ issue: Issue) -> ()
    
    
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
                        issueSyncCallBack({
                            isIssueRefreshing = false
                        })
                    } label: {
                        Image(systemName: AppConst.downloadIcon)
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
                        createIssue()
                    } label: {
                        Image(systemName: AppConst.plusIcon)
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

extension NoteIssuesHeaderView {
    
    func createIssue() -> Void {
        isNewIssueSending = true
        let title = AppConst.issueMarkdown
        let body = AppConst.issueBodyMarkdown
        Networking<Issue>().request(API.newIssue(title: title, body: body), writeCache: false, readCache: false, parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
            guard let issue = data?.first else {
                isNewIssueSending = false
                return
            }
            createIssueCallBack(issue)
            isNewIssueSending = false
        }
    }
}

//#Preview {
//    NoteIssuesHeaderView()
//}
