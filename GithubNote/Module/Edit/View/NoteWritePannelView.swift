//
//  NoteWritePannelView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/14.
//

import Foundation
import SwiftUI

struct NoteWritePannelView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var commentGroups: [Comment]
    
    @Binding var selectionRepo: RepoModel?
    @Binding var selectionIssue: Issue?
    
    @Binding var selectionComment: Comment?
    @Binding var issue: Issue?
    @Binding var showImageBrowser: Bool?
    
    @State var isPresented: Bool = false
    
    @State var markdownString: String?
    @State var editIsShown: Bool = false
    
    @State var uploadState: UploadType = .normal
    
    @Binding var showLoading: Bool
    
    @State private var workItem: DispatchWorkItem?
    @State private var cache: String = ""
    @State private var cacheUpdate: Int = 0
    
#if !MOBILE
    private var undoManager: UndoManager? {
        NSApplication.shared.windows.first?.undoManager
    }
#endif
    
    var body: some View {
        VStack {
            VStack (spacing: 0) {
                ZStack {
                    MarkdownWebView(markdownText: $markdownString.toUnwrapped(defaultValue: ""))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if editIsShown {
                        TextEditor(text: $markdownString.toUnwrapped(defaultValue: ""))
                            .transparentScrolling()
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
                    }
                    if !cache.isEmpty && editIsShown {
                        cacheItemView()
                    }
                }
#if !MOBILE
                .onChange(of: editIsShown, { _, newValue in
                    if !newValue {
                        ///When editing again, attempting to undo causes a crash.
                        undoManager?.removeAllActions()
                    }
                })
#endif
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                if let value = selectionComment?.updatedAt?.localTime(), !value.isEmpty {
                    bottomTimeView()
                }
                
            }
            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
            .toolbar {
                ToolbarItemGroup {
                    if selectionComment != nil {
                        NoteWritePannelTitleView(showImageBrowser: $showImageBrowser,
                                                 selectionRepo: $selectionRepo,
                                                 selectionIssue: $selectionIssue,
                                                 selectionComment: $selectionComment)
                        
                        Spacer()
                        operationViews()
                    }
                }
                
            }
            .onChange(of: selectionComment) { oldValue, newValue in
                if oldValue?.identifier != newValue?.identifier {
                    editIsShown = false
                    cache = ""
                    markdownString = newValue?.body
                    checkCacheData()
                }
            }
            .onChange(of: markdownString) { oldValue, newValue in
                if oldValue != newValue && editIsShown {
                    cache = ""
                    debounceUpdateCacheText()
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
                    Image(systemName: "network")
                        .font(.system(size: 10))
                        .padding(.trailing, 5)
                    Text(selectionComment?.updatedAt?.localTime() ?? "")
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
                    markdownString = cache
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
    
    fileprivate func operationViews() -> some View {
        
        HStack {
            if showImageBrowser! {
                HStack {
                    Button(action: {
                        isPresented = true
                    }, label: {
                        Image(systemName: AppConst.plusIcon)
                    })
                    .fileImporter(
                        isPresented: $isPresented,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: true
                    ) { result in
                        switch result {
                        case .success(let urls):
                            showLoading = true
                            ImageUploader.shared.uploadImages(urls: urls, completion: { _ in
                                showLoading = false
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
                    Button {
                        showImageBrowser = false
                    } label: {
                        Image(systemName: AppConst.closeIcon)
                    }
                }
            }
            if editIsShown && !showImageBrowser! {
                ZStack {
                    if uploadState == .sending {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Button {
                            if uploadState != .normal {
                                return
                            }
                            updateContent()
                        } label: {
                            Label("Show inspector", systemImage: uploadState.imageName)
                        }
                        .disabled(!editIsShown)
                    }
                }
                .frame(width: 30, height: 40)
            }
            if !(showImageBrowser ?? false) {
                Button {
                    editIsShown.toggle()
                } label: {
                    Label("Show inspector", systemImage: editIsShown ? AppConst.closeIcon : AppConst.pencilIcon)
                        .if(!editIsShown) { view in
                            view.font(.system(size: 18))
                        }
                }
                
            }
        }
    }
}

extension NoteWritePannelView {
    
    fileprivate func updateContent() -> Void {
        guard let body = markdownString, let commentid = selectionComment?.id else { return }
        uploadState = .sending
        
        Networking<Comment>().request(API.updateComment(commentId: commentid, body: body), parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
            
            guard let comment = data?.first else {
                uploadState = .fail
                normal()
                return
            }
            updateCommentData(comment) {
                normal()
            }
            func normal() -> Void {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    uploadState = .normal
                }
            }
        }
    }
    
    fileprivate func updateCommentData(_ comment: Comment, _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.updateComments([comment]) {
            CacheManager.fetchComments { localList in
                commentGroups = localList
                selectionComment = localList.first(where: {$0.id == comment.id})
                completion()
            }
        }
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
        guard var comment = selectionComment else { return }
        comment.cache = markdownString
        selectionComment = comment
        CacheManager.updateCommentCache(comment) {}
    }
    
    fileprivate func checkCacheData() -> Void {
        guard let commentId = selectionComment?.id else { return }
        CacheManager.fetchComment(commentId) { comment in
            cache = comment?.cache ?? ""
            cacheUpdate = comment?.cacheUpdate ?? 0
        }
    }
}
