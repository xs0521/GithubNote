//
//  NoteWritePannelTitleView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/19.
//

import Foundation
import Foundation
import SwiftUI

struct NoteWritePannelTitleView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var showImageBrowser: Bool?
    @Binding var selectionRepo: RepoModel?
    @Binding var selectionIssue: Issue?
    @Binding var selectionComment: Comment?
    
    var body: some View {
        
        HStack (spacing: 0) {
            if showImageBrowser == true {
                Text("")  // 空文本
            } else {
                HStack (spacing: 3) {
                    Image(systemName: "star.fill")
                    Text("\(Account.owner)")
                }
                
                if let repoName = selectionRepo?.name {
                    HStack (spacing: 3) {
                        Text("/")
                            .padding(.horizontal, 5)
                        Image(systemName: "square.stack.3d.up.fill")
                        Text(repoName)
                    }
                }
                
                if let issueName = selectionIssue?.title {
                    HStack (spacing: 3) {
                        Text("/")
                            .padding(.horizontal, 5)
                        Image(systemName: "menucard.fill")
                        Text(issueName)
                    }
                    
                }
                
                if let commentName = selectionComment?.body?.toTitle() {
                    HStack (spacing: 3) {
                        Text("/")
                            .padding(.horizontal, 5)
                        Image(systemName: "cup.and.saucer.fill")
                        Text(commentName)
                    }
                }
            }
        }
        .font(.system(size: 12))
        .foregroundColor(colorScheme == .dark ? Color(hex: "#DDDDDD") : Color(hex: "#444443"))
    }
}
