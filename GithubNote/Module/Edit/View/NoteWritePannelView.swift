//
//  NoteWritePannelView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/14.
//

import Foundation
import SwiftUI

struct NoteWritePannelView: View {
    
    private let formatter = DateFormatter()
    
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
    
    
    var body: some View {
        VStack {
            ZStack {
                MarkdownWebView(markdownText: $markdownString.toUnwrapped(defaultValue: ""))
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
                    .frame(maxWidth: .infinity, alignment: .leading)
                if editIsShown {
                    TextEditor(text: $markdownString.toUnwrapped(defaultValue: ""))
                        .transparentScrolling()
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
                        .padding(.leading, 16)
                    
                }
                VStack {
                    CustomDivider()
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
            .toolbar {
                ToolbarItemGroup {
                    titleView()
                    
                    Spacer()
                    
                    if showImageBrowser! {
                        HStack {
                            Button(action: {
                                isPresented = true
                            }, label: {
                                Image(systemName: "plus")
                            })
                            .fileImporter(
                                isPresented: $isPresented,
                                allowedContentTypes: [.image]
                            ) { result in
                                switch result {
                                case .success(let url):
                                    _ = url.startAccessingSecurityScopedResource()
                                    uploadImage(filePath: url)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            Button {
                                NotificationCenter.default.post(name: NSNotification.Name.syncNetImagesNotification, object: nil)
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            Button {
                                showImageBrowser = false
                            } label: {
                                Image(systemName: "xmark.circle")
                            }
                        }
                    }
                    if editIsShown && !showImageBrowser! {
                        Button(action: {
                            showImageBrowser?.toggle()
                        }, label: {
                            Image(systemName: "photo.on.rectangle.angled")
                        })
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
                            Label("Show inspector", systemImage: editIsShown ? "xmark.circle" : "square.and.pencil")
                            //                                .font(.system(size: editIsShown ? 14 : 16))
                            //                                .fontWeight(editIsShown ? .regular : .bold)
                        }
                    }
                }
                
            }
            .onChange(of: selectionComment) { oldValue, newValue in
                if oldValue?.identifier != newValue?.identifier {
                    markdownString = newValue?.body
                }
            }
        }
    }
    
    private func titleView() -> some View {
        
        HStack (spacing: 0) {
            if showImageBrowser == true {
                Text("")  // 空文本
            } else {
                HStack (spacing: 3) {
                    Image(systemName: "star")
                    Text("\(Account.owner)")
                }
                
                if let repoName = selectionRepo?.name {
                    HStack (spacing: 3) {
                        Text(">")
                            .padding(.horizontal, 5)
                        Image(systemName: "square.stack.3d.up")
                        Text(repoName)
                    }
                }
                
                if let issueName = selectionIssue?.title {
                    HStack (spacing: 3) {
                        Text(">")
                            .padding(.horizontal, 5)
                        Image(systemName: "menucard")
                        Text(issueName)
                    }
                    
                }
                
                if let commentName = selectionComment?.body?.toTitle() {
                    HStack (spacing: 3) {
                        Text(">")
                            .padding(.horizontal, 5)
                        Image(systemName: "cup.and.saucer")
                        Text(commentName)
                            .layoutPriority(1)
                    }
                }
            }
        }
        .foregroundColor(colorScheme == .dark ? Color(hex: "#DDDDDD") : Color(hex: "#444443"))
        
        //        .foregroundColor(colorScheme == .dark ? Color.init(hex: "#DDDDDD") : Color.init(hex: "#444443"))
        
        //        if showImageBrowser == true {
        //            return ""
        //        }
        //
        //        var title = "\(Account.owner)"
        //        if let repoName = selectionRepo?.name {
        //            title += " > \(repoName)"
        //        }
        //        if let issueName = selectionIssue?.title {
        //            title += " > \(issueName)"
        //        }
        //        if let commentName = comment?.body?.toTitle() {
        //            title += " > \(commentName)"
        //        }
        //        return title
    }
    
    private func updateContent() -> Void {
        guard let body = markdownString, let commentid = selectionComment?.id else { return }
        uploadState = .sending
        
        Networking<Comment>().request(API.updateComment(commentId: commentid, body: body), writeCache: false, readCache: false, parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
            
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
    
    private func updateCommentData(_ comment: Comment, _ completion: @escaping CommonCallBack) -> Void {
        CacheManager.updateComments([comment]) {
            CacheManager.fetchComments { localList in
                commentGroups = localList
                selectionComment = localList.first(where: {$0.id == comment.id})
                completion()
            }
        }
    }
    
    private func uploadImage(filePath: URL) -> Void {
        
        showLoading = true
        
        DispatchQueue.global().async(execute: {
            let data = try? Data(contentsOf: filePath)
            guard let data = data, !data.isEmpty else { return }
            let imageBase64 = data.base64EncodedString()
            
            let pathExtension = filePath.pathExtension
            let fileName = fileName() + ".\(pathExtension)"
            
            Networking<PushCommitModel>().uploadImage(API.updateImage(imageBase64: imageBase64, fileName: fileName)) { _ in
            } completionModelHandler: { data, cache, code in
                
                showLoading = false
                
                if code != MessageCode.createSuccess.rawValue {
                    return
                }
                
                guard let item = data?.first else { return }
                
                let content = item.content
                let encoder = JSONEncoder()
                let decoder = JSONDecoder()
                
                do {
                    let data = try encoder.encode(content)
                    let githubImage = try decoder.decode(GithubImage.self, from: data)
                    CacheManager.shared.appendImage(githubImage, repoName: Account.repo)
                } catch let err {
                    print(err)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name.syncLocalImagesNotification, object: nil)
            }
            
        })
    }
    
    func fileName() -> String {
        let now = Date()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: now)
    }
}
