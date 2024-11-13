//
//  NoteCommentsHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteCommentsHeaderView: View {
    
    var body: some View {
        
        CustomHeaderView(title: "Note") { callBack in
            store.dispatch(action: CommentActions.FetchList(readCache: false, showTip: true, completion: { finish in
                callBack()
            }))
        } newCallBack: { callBack in
            store.dispatch(action: CommentActions.Create(completion: { finish in
                store.dispatch(action: CommentActions.FetchList(readCache: true, completion: { _ in
                    callBack()
                }))
            }))
        }

    }
}
