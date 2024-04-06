//
//  WritePannel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/25.
//

import Foundation
import SwiftUI
import MarkdownUI
import Splash

struct WritePannelView: View {
    
    @Binding var markdownString: String
    @Binding var commentId: Int
    @Binding var issuesNumber: Int
    
    @State var uploadState: UploadType = .normal
//    arrow.up.circle.fill
//    checkmark.circle.fill
    
    var body: some View {
        ZStack {
            HStack (spacing: 0) {
                ZStack {
                    ScrollView(.vertical) {
                        Markdown(markdownString)
                            .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                            .markdownImageProvider(.default)
                            .markdownTheme(.gitHub)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(.red)
                    }
//                    .background(.blue)
                    if  markdownString.isEmpty {
                        Image(systemName: EmptyModel.figureArray.randomElement() ?? "")
                            .font(.system(size: 30))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                ZStack {
                    TextEditor(text: $markdownString)
                        .font(.title3)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
//                        .background(.orange)
                    if markdownString.isEmpty {
                        Image(systemName: EmptyModel.figureArray.randomElement() ?? "")
                            .font(.system(size: 30))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if !markdownString.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            uploadState = .sending
                            Request.updateComment(content: markdownString, commentId: "\(commentId)") { res in
                                uploadState = res ? .success : .fail
                                changeToNormal()
                            }
                        }, label: {
                            Image(systemName: uploadState.imageName)
                                .font(.system(size: 40))
                        })
                        .buttonStyle(.plain)
                        .frame(width: 80, height: 80)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                }
            }
        }
    }
    
    
    func changeToNormal() -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.uploadState = .normal
        })
        
    }
    
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        return .sunset(withFont: .init(size: 16))
    }
}
