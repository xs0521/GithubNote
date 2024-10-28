//
//  NoteSidebarToolView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/7.
//

import SwiftUI

struct NoteSidebarToolView: View {
    
    @Binding var showReposView: Bool
    
    @Binding var showImageBrowser: Bool?
    @Binding var selectionRepo: RepoModel?
    
    @State private var isSyncRepos: Bool = false
    @State private var isCreateRepos: Bool = false
    @State private var repoTitle: String = "Select Repo"
    
    @State private var degreesValue: Double = 0
    
    var requestAllRepoCallBack: (_ cache: Bool, _ callBack: @escaping CommonCallBack) -> Void
    
    var body: some View {
        HStack {
            Button(action: {
//                showReposView.toggle()
                let showReposView = !store.state.sideStates.showReposView
                store.dispatch(action: SideActions.ReposViewState(show: showReposView))
            }, label: {
                Label {
                    HStack {
                        Text(repoTitle)
                            .lineLimit(1)
                        if selectionRepo?.private == true {
                            PrivateTagView()
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
                HStack {
                    if isSyncRepos {
                        ProgressView()
                            .controlSize(.mini)
                            .padding()
                            .padding(.trailing, 5)
                            .frame(width: 20, height: 15)
                    } else {
                        Button {
                            isSyncRepos = true
                            requestAllRepoCallBack(false, {
                                isSyncRepos = false
                            })
                        } label: {
                            Image(systemName: AppConst.downloadIcon)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 5)
                    }
                    if isCreateRepos {
                        ProgressView()
                            .controlSize(.mini)
                            .padding()
                            .padding(.trailing, 5)
                            .frame(width: 15, height: 15)
                    } else {
                        Button {
                            isCreateRepos = true
                            createRepo { success in
                                isCreateRepos = false
                            }
                        } label: {
                            Image(systemName: AppConst.plusIcon)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 40)
                .padding(EdgeInsets(top: 5, leading: 16, bottom: 16, trailing: 10))
            } else {
                Button(action: {
                    if CacheManager.shared.currentRepo == nil {
                        ToastManager.shared.show("Please select a code repository")
                        return
                    }
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

extension NoteSidebarToolView {
    
    func createRepo(_ completion: @escaping CommonTCallBack<Bool>) -> Void {
        
        let noteRepoName = AppConst.noteRepo
        
        Networking<RepoModel>().request(API.createRepo(repoName: noteRepoName), parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
            
            guard let list = data, let item = list.first else {
                "#request# createRepo error".logE()
                completion(false)
                return
            }
            
            "#request# createRepo \(noteRepoName)".logI()
            
            CacheManager.insertRepos(repos: [item]) {
                self.requestAllRepoCallBack(true, {
                    completion(true)
                })
            }
        }
    }
}
