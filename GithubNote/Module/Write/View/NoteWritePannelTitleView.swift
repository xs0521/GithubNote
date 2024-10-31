//
//  NoteWritePannelTitleView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/19.
//

import Foundation
import SwiftUI
import SwiftUIFlux

struct NoteWritePannelTitleView: ConnectedView {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var commentStore: CommentModelStore
    @EnvironmentObject var repoStore: RepoModelStore
    @EnvironmentObject var issueStore: IssueModelStore
    
    struct Props {
        let isImageBrowserVisible: Bool
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isImageBrowserVisible: state.imagesState.isImageBrowserVisible)
    }
    
    func body(props: Props) -> some View {
        
        HStack (spacing: 0) {
            if props.isImageBrowserVisible == true {
                Text("")
            } else {
                itemView(title: UserManager.shared.user?.login ?? "", icon: "star.fill", isFirst: true)
                if let repoName = repoStore.select?.name {
                    itemView(title: repoName, icon: "square.stack.3d.up.fill")
                }
                if let issueName = issueStore.select?.title {
                    itemView(title: issueName, icon: "menucard.fill")
                }
                if let commentName = commentStore.select?.body?.toTitle() {
                    itemView(title: commentName, icon: "note.text")
                }
            }
        }
        .font(.system(size: 12))
        .foregroundColor(colorScheme == .dark ? Color(hex: "#DDDDDD") : Color(hex: "#444443"))
    }
    
    func itemView(title: String, icon: String, isFirst: Bool = false) -> some View {
        HStack (spacing: 3) {
            if !isFirst {
                Text("/")
                    .padding(.horizontal, 5)
            }
            Image(systemName: icon)
            Text(title)
        }
    }
}
