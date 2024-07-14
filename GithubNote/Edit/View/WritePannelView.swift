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
    
    @State var markdownString: String?
    @Binding var comment: Comment?
    @Binding var issue: Issue?
    
    @State var uploadState: UploadType = .normal
    @State var editMaxMode: ContentMaxWidthType = Account.editMode
    
    var body: some View {
        ZStack {
            HStack (spacing: 0) {
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
//                    .background(.blue)
                    if markdownString == nil || markdownString!.isEmpty {
                        Image(systemName: EmptyModel.figureArray.randomElement() ?? "")
                            .font(.system(size: 30))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                    .padding(.bottom, 30)
                ZStack {
                    TextEditor(text: $markdownString.toUnwrapped(defaultValue: ""))
                        .font(.system(size: 14))
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
//                        .background(.orange)
                    if markdownString == nil || markdownString!.isEmpty {
                        Image(systemName: EmptyModel.figureArray.randomElement() ?? "")
                            .font(.system(size: 30))
                            .symbolRenderingMode(.hierarchical)
                    }
                    if editMaxMode == .mini {
                        VStack {}
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white)
                    }
                }
                .frame(maxWidth: editMaxMode == .normal ? .infinity : AppConst.editItemMinWidth, maxHeight: .infinity)
            }
            if let content = markdownString,!content.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            editMaxMode = editMaxMode == .mini ? .normal : .mini
                            Account.saveEditMode(editMaxMode)
                        }, label: {
                            Image(systemName: editMaxMode == .normal ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 20))
                                .symbolRenderingMode(.hierarchical)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                        })
                        .buttonStyle(.plain)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: editMaxMode == .normal ? 0 : 10))
                        Spacer()
                        if editMaxMode == .normal {
                            Button(action: {
                                uploadState = .sending
                                Request.updateComment(content: markdownString ?? "", commentId: "\(comment?.commentid ?? 0)") { res in
                                    uploadState = res ? .success : .fail
                                    changeToNormal()
                                }
                            }, label: {
                                Image(systemName: uploadState.imageName)
                                    .font(.system(size: 40))
                                    .symbolRenderingMode(.hierarchical)
                            })
                            .buttonStyle(.plain)
                            .frame(width: 80, height: 80)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        }
                    }
                    
                }
            }
        }
        .onChange(of: comment) { oldValue, newValue in
            if oldValue?.commentid != newValue?.commentid {
                markdownString = newValue?.body
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
        return .sunset(withFont: .init(size: 14))
    }
}
