//
//  NoteImageBrowserView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/17.
//

import SwiftUI
import SDWebImageSwiftUI

struct NoteImageBrowserView: View {
    
    @State var animated = false
    
    @Binding var showImageBrowser: Bool?
    
    @State var data: [GithubImage] = []

    var body: some View {
        NoteImageBrowserImagesView(showImageBrowser: $showImageBrowser,
                                   data: $data)
            .background(Color.white)
            .opacity(animated ? 1.0 : 0.0)
            .onAppear(perform: {
                let baseAnimation = Animation.easeInOut(duration: 0.6)
                withAnimation(baseAnimation) {
                    animated = true
                }
                requestImagesData()
            })
    }
    
    func requestImagesData() -> Void {

        Networking<GithubImage>().request(API.repoImages, writeCache: false, readCache: false) { data, cache in
            guard let list = data else {
                return
            }
            self.data = list
        }
    }
}

struct NoteImageBrowserImagesView: View {
    
    @Binding var showImageBrowser: Bool?
    @Binding var data: [GithubImage]
    @State var showPreview: Bool = false
    @State var url: String = ""
    
    let adaptiveColumn = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var body: some View {
        ZStack {
            ScrollView (showsIndicators: false) {
                if data.isEmpty {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                        ForEach(data, id: \.self) { item in
                            Button(action: {
                                url = item.downloadURL
                                showPreview = true
                                
                            }, label: {
                                WebImage(url: URL(string: item.downloadURL))
                                .frame(width: 180, height: 180, alignment: .center)
                                .scaledToFit()
                                .cornerRadius(10)
                                .transition(.fade(duration: 0.3))
                                .foregroundColor(.gray)
                                .font(.title)
                            })
                        }
                    }
                }
            }
            .padding(.vertical, 160)
            .padding(.horizontal, 80)
            .background(Color.background)
            .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
            RoundedRectangle(cornerRadius: 0)
            .fill(
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.clear, Color.white]), startPoint: UnitPoint(x: 0.5, y: 0.0), endPoint: UnitPoint(x: 0.5, y: 1.0))
            )
            .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
            .allowsHitTesting(false)
            if showPreview {
                ZStack {
                    VStack {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        showPreview = false
                    }
                    WebImage(url: URL(string: url))
                    .frame(width: 500, height: 500, alignment: .center)
                    .scaledToFit()
                    .transition(.fade(duration: 0.3))
                    .onTapGesture {
                        showPreview = false
                    }
                }
                .contextMenu(menuItems: {
                    Button(action: {
                        let content = "![](\(url))"
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.setString(content, forType: .string)
                    }, label: {
                        Text("copy")
                    })
                })
            }
        }
    }
}
