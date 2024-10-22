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
    
    @State private var repoTitle: String = "Select Repo"
    
    @State private var degreesValue: Double = 0
    
    var requestAllRepoCallBack: CommonTCallBack<CommonCallBack>
    
    var body: some View {
        HStack {
            Button(action: {
                showReposView.toggle()
            }, label: {
                Label {
                    HStack {
                        Text(repoTitle)
                            .lineLimit(1)
                        if selectionRepo?.private == true {
                            Text("Private")
                                .foregroundColor(Color.white)
                                .font(.system(size: 6))
                                .padding(EdgeInsets(top: 2, leading: 3, bottom: 2, trailing: 3))
                                .background(Color.gray)
                                .cornerRadius(5)
                        }
                    }
                } icon: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .rotationEffect(.degrees(-degreesValue))
                }
                .foregroundStyle(Color.primary)
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding(EdgeInsets(top: 5, leading: 16, bottom: 16, trailing: 5))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: selectionRepo) { oldValue, newValue in
                repoTitle = selectionRepo?.name ?? "Select Repo"
            }
            .onChange(of: showReposView) { oldValue, newValue in
                degreesValue = newValue ? 90 : 0
            }
            
            if showReposView {
                if isSyncRepos {
                    ProgressView()
                        .controlSize(.mini)
                        .padding()
                        .padding(.trailing, 5)
                        .frame(width: 20, height: 20)
                } else {
                    Button {
                        isSyncRepos = true
                        requestAllRepoCallBack({
                            isSyncRepos = false
                        })
                    } label: {
                        Image(systemName: AppConst.downloadIcon)
                    }
                    .buttonStyle(.plain)
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 16, trailing: 16))
                }
            } else {
                Button(action: {
                    showImageBrowser?.toggle()
                }, label: {
                    Image(systemName: AppConst.photoIcon)
                })
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 16, trailing: 16))
            }
        }
    }
}
