//
//  NoteImageBrowserImagesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/29.
//

import SwiftUI
import SDWebImageSwiftUI
import AlertToast

struct NoteImageBrowserImagesView: View {
    
    static let size = CGSizeMake(100, 100)
    
    @Binding var showImageBrowser: Bool?
    
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @Binding var showLoading: Bool
    
    @State var showPreview: Bool = false
    @State var url: String = ""
    
    @State private var data: [GithubImage] = []
    
    @Environment(\.colorScheme) var colorScheme
    
    let adaptiveColumn = [
        GridItem(.adaptive(minimum: NoteImageBrowserImagesView.size.width, maximum: NoteImageBrowserImagesView.size.width))
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
                                ZStack {
                                    Color.init(hex: "#D2D2D3")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .opacity(0.3)
                                    WebImage(url: URL(string: item.imageUrl()))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    
                                }
                                .frame(width: NoteImageBrowserImagesView.size.width, height: NoteImageBrowserImagesView.size.height)
                                .cornerRadius(10)
                                .transition(.fade(duration: 0.3))
                            })
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("copy", role: .destructive) {
                                    copyAction(item.imageUrl())
                                }
                                Button("delete", role: .destructive) {
                                    deleteFile(item)
                                }
                            }
                            .onAppear {
                                
                            }
                            
                        }
                    }
                }
            }
            .padding(.vertical, 160)
            .padding(.horizontal, 80)
            .background(Color.clear)
            .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
            if showPreview {
                ZStack {
                    VStack {
                        colorScheme == .dark ? Color.init(hex: "#292929") : Color.init(hex: "#ECECEB")
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
                    Button("copy", role: .destructive) {
                        copyAction(url)
                    }
                })
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.syncNetImagesNotification), perform: { _ in
            showLoading = true
            requestImagesData(false, completion: { 
                showLoading = false
            })
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.appendImagesNotification), perform: { notification in
            if let item = notification.object as? GithubImage {
                data.append(item)
            }
        })
        .onAppear(perform: {
            showLoading = true
            requestImagesData {
                showLoading = false
            }
        })
        
    }
}

extension NoteImageBrowserImagesView {
    
    fileprivate func requestImagesData(_ readCache: Bool = true, completion: @escaping CommonCallBack) -> Void {
        
        if readCache {
            CacheManager.fetchGithubImages { images in
                self.data = images
                showLoading = false
                completion()
            }
            return
        }
        
        Networking<GithubImage>().request(API.repoImages) { data, cache, code in
            if code == MessageCode.notFound.rawValue {
                self.data.removeAll()
                requestCreateImageDir(completion: {
                    completion()
                })
                return
            }
            
            if let list = data, !list.isEmpty {
                let images = list.filter({$0.path.isImage()})
                CacheManager.insertGithubImages(images: images, deleteNoFound: true) {
                    CacheManager.fetchGithubImages { localImages in
                        self.data = localImages
                        completion()
                    }
                }
            } else {
                self.data.removeAll()
                completion()
            }
            
        }
    }
    
    fileprivate func requestCreateImageDir(completion: @escaping CommonCallBack) -> Void {
        
        Networking<PushCommitModel>().request(API.createImagesDirectory, writeCache: false, readCache: false) { data, cache, code in
            completion()
            if code != MessageCode.createSuccess.rawValue {
                return
            }
            "ImageDir success".logI()
        }
        
    }
    
    fileprivate func deleteFile(_ item: GithubImage) -> Void {
        self.showLoading = true
        Networking<PushCommitModel>().request(API.deleteImage(filePath: item.path, sha: item.sha), writeCache: false, readCache: false) { _, cache, code in
            if code == MessageCode.success.rawValue {
                data = data.filter({$0.identifier != item.identifier})
                CacheManager.deleteGithubImage(item.url) {
                    self.showLoading = false
                }
            } else {
                self.showLoading = false
            }
        }
    }
    
    fileprivate func copyAction(_ url: String) -> Void {
        let content = """
        <img src="\(url)" alt="alt text" width="300" height="200">
        """
        
#if MOBILE
#else
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(content, forType: .string)
#endif
        toastMessage = "done"
        showToast = false
        showToast.toggle()
    }
}
