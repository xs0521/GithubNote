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
    
    @Binding var commentGroups: [Comment]
    
    @Binding var comment: Comment?
    @Binding var issue: Issue?
    
    @State var markdownString: String?
    @State var editIsShown: Bool = false
    
    @State var uploadState: UploadType = .normal
    
    var body: some View {
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
        .toolbar {
            ToolbarItemGroup {
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
           
        }
        .inspector(isPresented: $editIsShown) {
            Group {
                TextEditor(text: $markdownString.toUnwrapped(defaultValue: ""))
                    .font(.system(size: 14))
                    .inspectorColumnWidth(min: 100, ideal: 500, max: 800)
            }
        }
        .onChange(of: comment) { oldValue, newValue in
            if oldValue?.commentid != newValue?.commentid {
                markdownString = newValue?.body
            }
        }
    }
    
    
    private func updateContent() -> Void {
        guard let markdownString = markdownString, let commentid = comment?.commentid else { return }
        uploadState = .sending
        Request.updateComment(content: markdownString, commentId: "\(commentid)") { success in
            uploadState = success ? .success : .fail
            if success {
                updateComment(commentid, markdownString)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                uploadState = .normal
            }
        }
    }
    
    func updateComment(_ commentid: Int, _ body: String) -> Void {
        guard let index = commentGroups.firstIndex(where: {$0.commentid == commentid}) else {
            return
        }
        let oldComment = commentGroups[index]
        var list = commentGroups
        list[index] = oldComment.newComment(body)
        commentGroups.removeAll()
        commentGroups = list
    }
    
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        return .sunset(withFont: .init(size: 14))
    }
}
