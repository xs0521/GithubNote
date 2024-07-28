//
//  NoteImageBrowserView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/17.
//

import SwiftUI
import SDWebImageSwiftUI
import AlertToast

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
            .onTapGesture {
                showImageBrowser = false
            }
    }
    
    func requestImagesData() -> Void {

        Networking<GithubImage>().request(API.repoImages, writeCache: false, readCache: false) { data, cache, code in
            
            if code == MessageCode.notFound.rawValue {
                self.data.removeAll()
                requestCreateImageDir()
                return
            }
            guard let list = data else {
                self.data.removeAll()
                return
            }
            let images = list.filter({$0.path.isImage()})
            self.data = images
        }
    }
    
    func requestCreateImageDir() -> Void {
        
        Networking<PushCommitModel>().request(API.createImagesDirectory, writeCache: false, readCache: false) { data, cache, code in
            if code != MessageCode.createSuccess.rawValue {
                return
            }
        }
        
    }
}

struct NoteImageBrowserImagesView: View {
    
    static let size = CGSizeMake(100, 100)
    
    @Binding var showImageBrowser: Bool?
    @Binding var data: [GithubImage]
    @State var showPreview: Bool = false
    @State var url: String = ""
    
    @State private var showToast = false
    @State private var toastMessage = "copy"
    
    let adaptiveColumn = [
        GridItem(.adaptive(minimum: NoteImageBrowserImagesView.size.width))
    ]
    
    var body: some View {
        ZStack {
            ScrollView (showsIndicators: false) {
                if data.isEmpty {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                } else {
                    LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                        ForEach(data, id: \.self) { item in
                            Button(action: {
                                url = item.imageUrl()
                                showPreview = true
                            }, label: {
                                WebImage(url: URL(string: item.imageUrl()))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: NoteImageBrowserImagesView.size.width,
                                           height: NoteImageBrowserImagesView.size.height, alignment: .center)
                                    .cornerRadius(10)
                                    .transition(.fade(duration: 0.3))
                                    .foregroundColor(.gray)
                            })
                            
                            .onTapGesture(count: 2, perform: {
                                let content = "![](\(url))"
                                let pasteBoard = NSPasteboard.general
                                pasteBoard.clearContents()
                                pasteBoard.setString(content, forType: .string)
                                showToast = false
                                showToast.toggle()
                            })
                            .onTapGesture(count: 1, perform: {
                                url = item.imageUrl()
                                showPreview = true
                            })
                            
                        }
                    }
                }
            }
            .padding(.vertical, 160)
            .padding(.horizontal, 80)
            .background(Color.background)
            .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
//            RoundedRectangle(cornerRadius: 0)
//            .fill(
//                LinearGradient(gradient: Gradient(colors: [Color.white, Color.clear, Color.white]), startPoint: UnitPoint(x: 0.5, y: 0.0), endPoint: UnitPoint(x: 0.5, y: 1.0))
//            )
//            .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
//            .allowsHitTesting(false)
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
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 500, height: 500, alignment: .center)
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
        .toast(isPresenting: $showToast, duration: 2.0, tapToDismiss: true){
            AlertToast(type: .regular, title: toastMessage)
        }
    }
}
