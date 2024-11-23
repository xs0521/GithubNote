//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import Combine
import SwiftUIFlux

#if MOBILE
import UIKit
#else
import AppKit
#endif

struct NoteSidebarView: ConnectedView {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var alertStore: AlertModelStore
    
    struct Props {
        let isReposVisible: Bool
        let isIssuesVisible: Bool
        let isImageBrowserVisible: Bool
        let issuesHeight: CGFloat
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isReposVisible: state.sideStates.isReposVisible, 
                     isIssuesVisible: state.sideStates.isIssuesVisible,
                     isImageBrowserVisible: state.imagesState.isImageBrowserVisible,
                     issuesHeight: state.issuesStates.issuesHeight)
    }
    
    func body(props: Props) -> some View {
        VStack {
            ZStack {
                VStack (spacing: 0) {
                    NoteIssuesHeaderView()
                    NoteIssuesView()
                    NoteCommentsHeaderView()
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = props.issuesHeight + value.translation.height
                                    let issuesHeight = min(800, max(115, newHeight))
                                    AppUserDefaults.issuesHeight = issuesHeight
                                    store.dispatch(action: IssuesActions.HeightAction(value: issuesHeight))
                                }
                                .onEnded { value in
                                    "Drag ended, final height: \(props.issuesHeight)".logI()
                                }
                        )
                    NoteCommentsView()
                }
#if !MOBILE
                .frame(minWidth: 200)
#endif
                if props.isIssuesVisible {
                    NoteIssuesView()
                }
                
                if props.isReposVisible {
                    NoteReposView()
                }
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.keyboard), perform: { notification in
            if let event = notification.object as? NSEvent {
                handleKeyDown(event: event, props: props)
            }
        })
#if MOBILE
        .background(colorScheme == .dark ? Color.init(hex: "#1C1C1E") : Color.init(hex: "#F2F2F7"))
#endif
//        .safeAreaInset(edge: .bottom) {
//            NoteSidebarToolView()
//        }
    }
    
#if !MOBILE
    // 键盘事件处理
    func handleKeyDown(event: NSEvent, props: Props) {
        if event.modifierFlags.contains(.command) && event.characters == KeyboardType.insertImage.character {
            if CacheManager.shared.currentRepo == nil {
                ToastManager.shared.show("select_workspace".language())
                return
            }
            let isImageBrowserVisible = props.isImageBrowserVisible
            store.dispatch(action: ImagesActions.isImageBrowserVisible(on: !isImageBrowserVisible))
        }
        if event.modifierFlags.contains(.command) && event.characters == KeyboardType.WorkSpace.character {
            let visible = !store.state.sideStates.isReposVisible
            store.dispatch(action: SideActions.ReposViewState(visible: visible))
        }
    }
#endif
}
