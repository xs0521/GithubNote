//
//  NoteImageBrowserView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/17.
//

import SwiftUI
import SDWebImageSwiftUI
import AlertToast

struct NoteImageBrowserView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appStore: AppModelStore
    
    var body: some View {
        ZStack {
            NoteImageBrowserImagesView()
            .background(colorScheme == .dark ? Color.init(hex: "#292929") : Color.init(hex: "#ECECEB"))
            .onTapGesture {
                store.dispatch(action: ImagesActions.isImageBrowserVisible(on: false))
            }
        }
        .toast(isPresenting: $appStore.isToastVisible, duration: 2.0, tapToDismiss: true){
            AlertToast(displayMode: .hud, type: .systemImage("party.popper", .primary), title: appStore.toastMessage)
        }
        .toast(isPresenting: $appStore.isLoadingVisible){
            AlertToast(type: .loading, title: nil, subTitle: nil)
        }
    }
}


