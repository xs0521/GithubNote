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
    
    
//    @Binding var showLoading: Bool
    
    @State private var isPresented: Bool = false
    @State private var workItem: DispatchWorkItem?
    @State private var cache: String = ""
    @State private var cacheUpdate: Int = 0
    
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
                    if !cache.isEmpty && props.editIsShown {
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
                ToolbarItemGroup {
                    if commentStore.select != nil {
//                        NoteWritePannelTitleView(showImageBrowser: showImageBrowser,
//                                                 selectionRepo: $selectionRepo,
//                                                 selectionIssue: $selectionIssue,
//                                                 selectionComment: $selectionComment)
                        
                        Spacer()
                        operationViews(props: props)
                    }
                }
                
            }
//            .onChange(of: selectionComment) { oldValue, newValue in
//                if oldValue?.identifier != newValue?.identifier {
//                    editIsShown = false
//                    cache = ""
//                    markdownString = newValue?.body
//                    checkCacheData()
//                }
//            }
//            .onChange(of: markdownString) { oldValue, newValue in
//                if oldValue != newValue && editIsShown {
//                    cache = ""
//                    debounceUpdateCacheText()
//                }
//            }
        }
    }
}

extension NoteWritePannelView {
    
    fileprivate func bottomTimeView() -> some View {
        
        HStack {
            HStack {
                HStack (spacing: 0) {
                    Image(systemName: "network")
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
                    writeStore.markdownString = cache
                    cache = ""
                } label: {
                    Image(systemName: "timer")
                    Text(cacheUpdate.localTime())
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
                        Image(systemName: AppConst.plusIcon)
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
                        Image(systemName: AppConst.downloadIcon)
                    }
                    .buttonStyle(.plain)
                    Button {
                        store.dispatch(action: ImagesActions.isImageBrowserVisible(on: false))
                    } label: {
                        Image(systemName: AppConst.closeIcon)
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
                            updateContent()
                        } label: {
                            Label("Show inspector", systemImage: props.uploadState.imageName)
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
                    Label("Show inspector", systemImage: props.editIsShown ? AppConst.closeIcon : AppConst.pencilIcon)
                        .if(!props.editIsShown) { view in
                            view.font(.system(size: 18))
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension NoteWritePannelView {
    
    fileprivate func updateContent() -> Void {
        guard let body = writeStore.markdownString, let commentid = commentStore.select?.id else { return }
        
        store.dispatch(action: WriteActions.upload(state: .sending))
        
        Networking<Comment>().request(API.updateComment(commentId: commentid, body: body), parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
            
            guard let comment = data?.first else {
                store.dispatch(action: WriteActions.upload(state: .fail))
                normal()
                return
            }
            updateCommentData(comment) {
                normal()
            }
            func normal() -> Void {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    store.dispatch(action: WriteActions.upload(state: .normal))
                }
            }
        }
    }
    
    fileprivate func updateCommentData(_ comment: Comment, _ completion: @escaping CommonCallBack) -> Void {
//        CacheManager.updateComments([comment]) {
//            CacheManager.fetchComments { localList in
//                commentGroups = localList
//                selectionComment = localList.first(where: {$0.id == comment.id})
//                completion()
//            }
//        }
    }
    
    fileprivate func debounceUpdateCacheText() {
        workItem?.cancel()
        workItem = DispatchWorkItem {
            updateCacheText()
        }
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    fileprivate func updateCacheText() {
        guard var comment = commentStore.select else { return }
        comment.cache = writeStore.markdownString
        commentStore.select = comment
        CacheManager.updateCommentCache(comment) {}
    }
    
    fileprivate func checkCacheData() -> Void {
        guard let commentId = commentStore.select?.id else { return }
        CacheManager.fetchComment(commentId) { comment in
            cache = comment?.cache ?? ""
            cacheUpdate = comment?.cacheUpdate ?? 0
        }
    }
}
