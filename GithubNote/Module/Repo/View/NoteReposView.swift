//
//  NoteReposView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI
import Combine
import SwiftUIFlux

struct NoteReposView: ConnectedView {
    
    struct Props {
        let list: [RepoModel]
    }
    
    @EnvironmentObject var repoStore: RepoModelStore

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(list: state.reposStates.items)
    }
    
    func body(props: Props) -> some View {
        VStack {
            if props.list.isEmpty {
                NoteEmptyView()
                    .background(Color.background)
            } else {
                List(selection: $repoStore.select) {
                    ForEach(props.list) { selection in
                        Label(title: {
                            HStack {
                                Text(selection.name ?? "unknow")
                                    .font(.system(size: 12))
                                if selection.private == true {
                                    PrivateTagView()
                                }
                            }
                        }, icon: {
                            CustomImage(systemName: "square.stack.3d.up")
                                .foregroundStyle(Color.primary)
                        })
                        .tag(selection)
                    }
                }
                .background(Color.background)
            }
        }
        .onAppear(perform: {
            repoStore.listener.loadPage()
        })
    }
}
