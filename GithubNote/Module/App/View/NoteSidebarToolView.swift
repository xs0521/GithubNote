//
//  NoteSidebarToolView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/7.
//

import SwiftUI

struct NoteSidebarToolView: View {
    
    @Binding var showReposView: Bool
    @Binding var isSyncRepos: Bool
    @Binding var showImageBrowser: Bool?
    @Binding var selectionRepo: RepoModel?
    
    var requestAllRepoCallBack: CommonTCallBack<CommonCallBack>
    
    var body: some View {
        HStack {
            Button(action: {
                showReposView = !showReposView
            }, label: {
                if selectionRepo != nil {
                    Label((selectionRepo?.name ?? ""), systemImage: "chevron.right")
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                } else {
                    Label("Repos", systemImage: "chevron.right")
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                }
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding(EdgeInsets(top: 5, leading: 16, bottom: 16, trailing: 5))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if showReposView {
                if isSyncRepos {
                    ProgressView()
                        .controlSize(.mini)
                        .padding()
                        .padding(.trailing, 5)
                } else {
                    Button {
                        isSyncRepos = true
                        requestAllRepoCallBack({
                            isSyncRepos = false
                        })
                    } label: {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    .buttonStyle(.plain)
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 16, trailing: 16))
                }
            } else {
                Button(action: {
                    showImageBrowser?.toggle()
                }, label: {
                    Image(systemName: "photo.on.rectangle.angled")
                })
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 16, trailing: 16))
            }
        }
    }
}
