//
//  NoteIssuesHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteIssuesHeaderView: View {
    
    var body: some View {
        CustomHeaderView(title: "NoteBook") { callBack in
            store.dispatch(action: IssuesActions.FetchList(readCache: false, completion: { finish in
                callBack()
            }))
        } newCallBack: { callBack in
            store.dispatch(action: IssuesActions.Create(completion: { finish in
                store.dispatch(action: IssuesActions.FetchList(readCache: true, completion: { _ in
                    callBack()
                }))
            }))
        }
    }
}

