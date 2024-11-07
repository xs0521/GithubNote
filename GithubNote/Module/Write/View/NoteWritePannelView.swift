//
//  NoteWritePannelView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/14.
//

import Foundation
import SwiftUI
import SwiftUIFlux

struct NoteWritePannelView: ConnectedView {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var writeStore: WriteModelStore
    @EnvironmentObject var commentStore: CommentModelStore
    @EnvironmentObject var appStore: AppModelStore
    
    struct Props {
        let editIsShown: Bool
        let isImageBrowserVisible: Bool?
        let uploadState: UploadType
    }
    
    @State private var isPresented: Bool = false
    
#if !MOBILE
    private var undoManager: UndoManager? {
        NSApplication.shared.windows.first?.undoManager
    }
#endif
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(editIsShown: state.writeStates.editIsShown,
                     isImageBrowserVisible: state.imagesState.isImageBrowserVisible,
                     uploadState: state.writeStates.uploadState)
    }
    
    func body(props: Props) -> some View {
        VStack {
            VStack (spacing: 0) {
                ZStack {
                    MarkdownWebView(markdownText: $writeStore.markdownString.toUnwrapped(defaultValue: ""))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if props.editIsShown {
                        TextEditor(text: $writeStore.markdownString.toUnwrapped(defaultValue: ""))
                            .transparentScrolling()
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
                    }
                    if !writeStore.cache.isEmpty && props.editIsShown {
                        cacheItemView()
                    }
                }
#if !MOBILE
                .onChange(of: props.editIsShown, { _, newValue in
                    if !newValue {
                        undoManager?.removeAllActions()
                    }
                })
#endif
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                if let value = commentStore.select?.updatedAt?.localTime(), !value.isEmpty {
                    bottomTimeView()
                }
                
            }
            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
            .toolbar {
                ToolbarItemGroup () {
                    if commentStore.select != nil {
                        NoteWritePannelTitleView()
                            .padding(.leading, 10)
                        Spacer()
                        operationViews(props: props)
                    }
                }
                
            }
        }
    }
}

extension NoteWritePannelView {
    
    fileprivate func bottomTimeView() -> some View {
        
        HStack {
            HStack {
                HStack (spacing: 0) {
                    CustomImage(systemName: "network")
                        .font(.system(size: 10))
                        .padding(.trailing, 5)
                    Text(commentStore.select?.updatedAt?.localTime() ?? "")
                        .font(.system(size: 10))
                        .foregroundColor(colorScheme == .dark ? Color(hex: "#DDDDDD") : Color(hex: "#444443"))
                }
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
            Spacer()
        }
    }
    
}

extension NoteWritePannelView {
    
    fileprivate func cacheItemView() -> some View {
        
        VStack {
            HStack {
                Spacer()
                Button {
                    writeStore.markdownString = writeStore.cache
                    writeStore.cache = ""
                } label: {
                    CustomImage(systemName: "timer")
                    Text(writeStore.cacheUpdate.localTime())
                }
                .font(.system(size: 8))
                .foregroundColor(Color.white)
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                .background {
                    Capsule()
                        .foregroundColor(colorScheme == .dark ? Color.init(hex: "#41403F") : Color.init(hex: "#737373"))
                }
            }
            Spacer()
        }
    }
}

extension NoteWritePannelView {
    
    fileprivate func operationViews(props: Props) -> some View {
        
        HStack {
            if props.isImageBrowserVisible! {
                HStack {
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
                            print(error.localizedDescription)
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
            if props.editIsShown && !props.isImageBrowserVisible! {
                ZStack {
                    if props.uploadState == .sending {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Button {
                            if props.uploadState != .normal {
                                return
                            }
                            store.dispatch(action: WriteActions.uploadState(value: .sending))
                            store.dispatch(action: WriteActions.upload(completion: { success in
                                if success {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        store.dispatch(action: WriteActions.uploadState(value: .normal))
                                    }
                                } else {
                                    store.dispatch(action: WriteActions.uploadState(value: .fail))
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        store.dispatch(action: WriteActions.uploadState(value: .normal))
                                    }
                                }
                            }))
                        } label: {
                            CustomImage(systemName: props.uploadState.imageName)
                        }
                        .buttonStyle(.plain)
                        .disabled(!props.editIsShown)
                    }
                }
                .frame(width: 30, height: 40)
            }
            if !(props.isImageBrowserVisible ?? false) {
                Button {
                    store.dispatch(action: WriteActions.edit(editIsShown: !props.editIsShown))
                } label: {
                    
                    CustomImage(systemName: props.editIsShown ? AppConst.closeIcon : AppConst.pencilIcon)
                    
//                    Label("Show inspector", systemImage: props.editIsShown ? AppConst.closeIcon : AppConst.pencilIcon)
//                        .if(!props.editIsShown) { view in
//                            view.font(.system(size: 18))
//                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
