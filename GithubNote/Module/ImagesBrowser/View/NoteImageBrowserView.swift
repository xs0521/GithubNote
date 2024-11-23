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
    
    @EnvironmentObject var appStore: AppModelStore
    @State private var isPresented: Bool = false
    
    var body: some View {
        ZStack {
            NoteImageBrowserImagesView()
            .background([Color.init(hex: "#292929"), Color.init(hex: "#ECECEB")])
            .onTapGesture {
                store.dispatch(action: ImagesActions.isImageBrowserVisible(on: false))
            }
        }
        .toolbar {
            ToolbarItemGroup () {
                Spacer()
                Button(action: {
                    isPresented = true
                }, label: {
                    CustomImage(systemName: AppConst.plusIcon)
                })
                .buttonStyle(.plain)
                .fileImporter(
                    isPresented: $isPresented,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: true
                ) { result in
                    switch result {
                    case .success(let urls):
                        appStore.isLoadingVisible = true
                        ImageUploader.shared.uploadImages(urls: urls, completion: { _ in
                            appStore.isLoadingVisible = false
                        })
                    case .failure(let error):
                        error.localizedDescription.logE()
                    }
                }
                Button {
                    NotificationCenter.default.post(name: NSNotification.Name.syncNetImagesNotification, object: nil)
                } label: {
                    CustomImage(systemName: AppConst.downloadIcon)
                }
                .buttonStyle(.plain)
                Button {
                    store.dispatch(action: ImagesActions.isImageBrowserVisible(on: false))
                } label: {
                    CustomImage(systemName: AppConst.closeIcon)
                }
                .buttonStyle(.plain)
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


