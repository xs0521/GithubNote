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
    @State private var isTapEmptyLoading: Bool = false

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(list: state.reposStates.items)
    }
    
    func body(props: Props) -> some View {
        VStack {
            if props.list.isEmpty {
                if isTapEmptyLoading {
                    ZStack {
                        ProgressView()
                            .controlSize(.mini)
                            .frame(width: 25, height: 25)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)
                } else {
                    NoteEmptyView(tapCallBack: {
                        isTapEmptyLoading = true
                        store.dispatch(action: ReposActions.FetchList(readCache: false, completion: { finish in
                            isTapEmptyLoading = false
                        }))
                    })
                    .background(Color.background)
                }
                
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
