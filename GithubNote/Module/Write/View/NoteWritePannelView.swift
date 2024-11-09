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
                    MarkdownWebView(markdownText: writeStore.markdownString ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if props.editIsShown {
                        TextEditor(text: $writeStore.editMarkdownString.toUnwrapped(defaultValue: ""))
                            .transparentScrolling()
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
                    }
                    if commentStore.select != nil {
                        VStack {
                            HStack {
                                
                            }
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? Color.init(hex: "#282828") : Color.white)
                            .opacity(0.1)
                            .onHover { isHovering in
                                if props.isImageBrowserVisible! {
                                    return
                                }
                                if isHovering {
                                    if props.uploadState == .no {
                                        store.dispatch(action: WriteActions.uploadState(value: .normal))
                                    }
                                } else {
                                    if props.uploadState == .normal {
                                        store.dispatch(action: WriteActions.uploadState(value: .no))
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    if !writeStore.cache.isEmpty {
                        cacheItemView()
                    }
                }
#if !MOBILE
                .onChange(of: props.editIsShown, { _, newValue in
                    if !newValue {
                        undoManager?.removeAllActions()
                        if let editText = writeStore.editMarkdownString {
                            writeStore.markdownString = editText
                        }
                    } else {
                        if let editText = writeStore.editMarkdownString {
                            writeStore.markdownString = editText
                        }
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.keyboard), perform: { notification in
            if let event = notification.object as? NSEvent {
                handleKeyDown(event: event, props: props)
            }
        })
    }
    
#if !MOBILE
//     键盘事件处理
    func handleKeyDown(event: NSEvent, props: Props) {
        if event.modifierFlags.contains(.command) && event.characters == "/" {
            store.dispatch(action: WriteActions.edit(editIsShown: !props.editIsShown))
        }
    }
#endif
}

extension NoteWritePannelView {
    
    fileprivate func bottomTimeView() -> some View {
        
        HStack {
            Spacer()
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
                .foregroundColor(colorScheme == .dark ? Color.init(hex: "#D4D4D4") : Color.init(hex: "#737372"))
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                .background {
                    Capsule()
                        .foregroundColor(colorScheme == .dark ? Color.init(hex: "#41403F") : Color.init(hex: "#F7F7F7"))
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.trailing, 20)
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
            } else {
                ZStack {
                    if props.uploadState == .sending {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Button {
                            if props.uploadState == .no {
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
                    }
                }
                .frame(width: 30, height: 40)
            }
        }
    }
}
