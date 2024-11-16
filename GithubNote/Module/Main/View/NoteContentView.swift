//
//  NoteContentView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI
import AlertToast
import SwiftUIFlux

struct NoteContentView: ConnectedView {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var commentStore: CommentModelStore
    @EnvironmentObject var appStore: AppModelStore
    
    struct Props {
        let isImageBrowserVisible: Bool
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isImageBrowserVisible: state.imagesState.isImageBrowserVisible)
    }
    
    func body(props: Props) -> some View {
        ZStack {
#if MOBILE
            VStack {
                NoteContentHeaderView()
                CustomDivider()
                NoteContentTableView(selectionRepo: $selectionRepo,
                                     selectionIssue: $selectionIssue,
                                     commentGroups: $commentGroups,
                                     selectionComment: $selectionComment)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
#else
            NavigationSplitView {
                NoteSidebarView()
            } detail: {
                writePannelView()
            }
            .blur(radius: props.isImageBrowserVisible ? 5 : 0, opaque: true)
            .onAppear(perform: {
                ToastManager.shared.homeCallBack = { (item) in
                    appStore.item = item
                    appStore.isToastVisible = true
                }
            })
            .toast(isPresenting: $appStore.isToastVisible, duration: 3.0, tapToDismiss: true){
                AlertToast(displayMode: appStore.item?.mode ?? .hud,
                           type: appStore.item?.type ?? .regular,
                           title: appStore.item?.title ?? "")
            }
            .toast(isPresenting: $appStore.isLoadingVisible){
                AlertToast(type: .loading, title: nil, subTitle: nil)
            }
#endif
            if props.isImageBrowserVisible {
                NoteImageBrowserView()
            }
            
        }
    }
    
    private func writePannelView() -> some View {
        ZStack {
            NoteWritePannelView()
            if commentStore.select == nil {
                NoteEmptyView(type: .coffee) {
                    
                }
                .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
            }
        }
        .background(Color.white)
    }
}
