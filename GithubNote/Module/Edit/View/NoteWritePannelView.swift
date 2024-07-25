//
//  NoteWritePannelView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/14.
//

import Foundation
import SwiftUI
import MarkdownUI
import Splash

struct NoteWritePannelView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var commentGroups: [Comment]
    
    @Binding var comment: Comment?
    @Binding var issue: Issue?
    @Binding var importing: Bool?
    
    @State var isPresented: Bool = false
    
    @State var markdownString: String?
    @State var editIsShown: Bool = false
    
    @State var uploadState: UploadType = .normal
    
    var body: some View {
        VStack {
            ZStack {
                ScrollView(.vertical) {
                    Markdown(markdownString ?? "")
                        .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                        .markdownImageProvider(.default)
                        .markdownTheme(.gitHub)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(colorScheme == .dark ? Color.markdownBackground : Color.white)
            .toolbar {
                ToolbarItemGroup {
                    if !(importing ?? false) {
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
                        Button {
                            editIsShown.toggle()
                        } label: {
                            Label("Show inspector", systemImage: "sidebar.right")
                        }
                    }
                    Spacer()
                    if importing! {
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
                            case .success(let file):
                                print(file.absoluteString)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                    if editIsShown {
                        Button(action: {
                            importing?.toggle()
                        }, label: {
                            Image(systemName: "photo.on.rectangle.angled")
                        })
                    }
                }
               
            }
            .inspector(isPresented: $editIsShown) {
                Group {
                    TextEditor(text: $markdownString.toUnwrapped(defaultValue: ""))
                        .transparentScrolling()
                        .font(.system(size: 14))
                        .inspectorColumnWidth(min: 100, ideal: 500, max: 800)
                }
                .background(Color.background)
            }
            .onChange(of: comment) { oldValue, newValue in
                if oldValue?.identifier != newValue?.identifier {
                    markdownString = newValue?.body
                }
            }
        }
    }
    
    
    private func updateContent() -> Void {
        guard let body = markdownString, let commentid = comment?.id else { return }
        uploadState = .sending
        
        Networking<Comment>().request(API.updateComment(commentId: commentid, body: body), writeCache: false, readCache: false, completionListHandler: nil) { data, cache in
            
            guard let comment = data else {
                uploadState = .fail
                normal()
                return
            }
            updateCommentData(comment)
            func normal() -> Void {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    uploadState = .normal
                }
            }
            normal()
        }
    }
    
    private func updateCommentData(_ comment: Comment) -> Void {
        guard let index = commentGroups.firstIndex(where: {$0.id == comment.id}) else {
            return
        }
        var list = commentGroups
        list[index] = comment
        commentGroups = list
        self.comment = comment
        
        guard let issueId = issue?.number else { return }
        CacheManager.shared.updateCommentsCacheData(commentGroups, issueId: issueId)
    }
    
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        return .sunset(withFont: .init(size: 14))
    }
}
