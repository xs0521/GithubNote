//
//  NoteWritePannelTitleView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/19.
//

import Foundation
import SwiftUI
import SwiftUIFlux

struct NoteWritePannelTitleView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var commentStore: CommentModelStore
    @EnvironmentObject var repoStore: RepoModelStore
    @EnvironmentObject var issueStore: IssueModelStore
    
    var body: some View {
        HStack (spacing: 0) {
            if let repoName = repoStore.select?.name {
                itemView(title: repoName, icon: "square.stack.3d.up.fill", isFirst: true)
            }
            if let issueName = issueStore.select?.title {
                itemView(title: issueName, icon: "menucard.fill")
            }
            if let commentName = commentStore.select?.body?.toTitle() {
                itemView(title: commentName, icon: "note.text")
            }
        }
        .font(.system(size: 12))
        .monospacedDigit()
        .foregroundColor(colorScheme == .dark ? Color(hex: "#DDDDDD") : Color(hex: "#8C919E"))
    }
    
    func itemView(title: String, icon: String, isFirst: Bool = false) -> some View {
        HStack (spacing: 0) {
            if !isFirst {
                CustomImage(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .padding(.horizontal, 5)
            }
            Text(title)
                .monospacedDigit()
        }
    }
}
