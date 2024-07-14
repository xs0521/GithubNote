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
    
    @Binding var comment: Comment?
    @Binding var issue: Issue?
    
    @State var markdownString: String?
    @State var editIsShown: Bool = false
    
    @State var isUploading: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Markdown(markdownString ?? "")
                    .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                    .markdownImageProvider(.default)
                    .markdownTheme(.gitHub)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
                    .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(.red)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                ZStack {
                    if isUploading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2.0, anchor: .center)
                    } else {
                        Button {
                            isUploading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                isUploading = false
                            }
                        } label: {
                            Label("Show inspector", systemImage: "icloud.and.arrow.up")
                        }
                    }
                }
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
                markdownString = newValue?.value
            }
        }
    }
    
    
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        return .sunset(withFont: .init(size: 14))
    }
}
