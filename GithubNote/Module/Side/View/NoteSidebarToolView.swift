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
    
    @EnvironmentObject var repoStore: RepoModelStore
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        let isReposVisible = state.sideStates.isReposVisible
        let isImageBrowserVisible = state.imagesState.isImageBrowserVisible
        let selectionRepo = state.sideStates.selectionRepo
        
        return Props(isReposVisible: isReposVisible,
                     isImageBrowserVisible: isImageBrowserVisible,
                     selectionRepo: selectionRepo)
    }
    
    func body(props: Props) -> some View {
        HStack (alignment: .center) {
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
                    CustomImage(systemName: "arrowtriangle.right.fill")
                        .rotationEffect(.degrees(props.isReposVisible ? -90 : 0))
                }
                .foregroundStyle(Color.primary)
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
    

}
