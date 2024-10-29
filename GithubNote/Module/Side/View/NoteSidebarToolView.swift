//
//  NoteSidebarToolView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/7.
//

import SwiftUI
import SwiftUIFlux

struct NoteSidebarToolView: ConnectedView {
    
    struct Props {
        let isReposVisible: Bool
        let isImageBrowserVisible: Bool
        let selectionRepo: RepoModel?
    }
    
    @State private var isSyncRepos: Bool = false
    @State private var isCreateRepos: Bool = false
    @State private var repoTitle: String = "Select Repo"
    
    @State private var degreesValue: Double = 0
    
    @EnvironmentObject var repoStore: RepoModelStore
    
//    var requestAllRepoCallBack: (_ cache: Bool, _ callBack: @escaping CommonCallBack) -> Void
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        let isReposVisible = state.sideStates.isReposVisible
        let isImageBrowserVisible = state.sideStates.isImageBrowserVisible
        let selectionRepo = state.sideStates.selectionRepo
        
        return Props(isReposVisible: isReposVisible,
                     isImageBrowserVisible: isImageBrowserVisible,
                     selectionRepo: selectionRepo)
    }
    
    func body(props: Props) -> some View {
        HStack {
            Button(action: {
                let visible = !store.state.sideStates.isReposVisible
                store.dispatch(action: SideActions.ReposViewState(visible: visible))
            }, label: {
                Label {
                    HStack {
                        Text(props.selectionRepo?.name ?? "Select Repo")
                            .lineLimit(1)
                        if props.selectionRepo?.private == true {
                            PrivateTagView()
                        }
                    }
                } icon: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .rotationEffect(.degrees(props.isReposVisible ? -90 : 0))
                }
                .foregroundStyle(Color.primary)
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding(EdgeInsets(top: 5, leading: 16, bottom: 16, trailing: 5))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if props.isReposVisible {
                HStack {
                    if isSyncRepos {
                        ProgressView()
                            .controlSize(.mini)
                            .padding()
                            .padding(.trailing, 5)
                            .frame(width: 20, height: 15)
                    } else {
                        Button {
//                            isSyncRepos = true
//                            requestAllRepoCallBack(false, {
//                                isSyncRepos = false
//                            })
                            isSyncRepos = true
                            repoStore.listener.loadPage(false, {_ in 
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
//                            isCreateRepos = true
//                            createRepo { success in
//                                isCreateRepos = false
//                            }
                            isCreateRepos = true
                            repoStore.listener.create { finish in
                                repoStore.listener.loadPage(true, {_ in
                                    isCreateRepos = false
                                })
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
                    store.dispatch(action: SideActions.ImagesViewState(visible: true))
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
//                self.requestAllRepoCallBack(true, {
//                    completion(true)
//                })
            }
        }
    }
}
