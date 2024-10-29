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
    
    struct Props {
        let isReposVisible: Bool
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isReposVisible: state.sideStates.isReposVisible)
    }
    
    func body(props: Props) -> some View {
        VStack {
            ZStack {
                VStack (spacing: 0) {
                    NoteCommentsHeaderView()
                    NoteCommentsView()
                    Spacer()
                    NoteIssuesHeaderView()
                    NoteIssuesView()
                }
    #if !MOBILE
                .frame(minWidth: 200)
    #endif
                if props.isReposVisible {
                    NoteReposView()
                }
            }
        }
#if MOBILE
        .background(colorScheme == .dark ? Color.init(hex: "#1C1C1E") : Color.init(hex: "#F2F2F7"))
#endif
        .safeAreaInset(edge: .bottom) {
            NoteSidebarToolView()
        }
    }
}
