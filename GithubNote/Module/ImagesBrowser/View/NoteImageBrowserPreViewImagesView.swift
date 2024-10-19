//
//  NoteImageBrowserPreViewImagesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/19.
//

import SwiftUI
import SDWebImageSwiftUI

struct NoteImageBrowserPreViewImagesView: View {
    
    @Binding var imageUrls: [GithubImage] // 图片URL数组
    @Binding var showPreview: Bool
    @State var selectedImageIndex: Int
    
    var copyCallBackAction: CommonTCallBack<String>
    
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                // 添加 NSViewRepresentable 以捕获键盘事件
                KeyCaptureViewRepresentable { event in
                    handleKeyDown(event: event)
                }
                .frame(width: 0, height: 0)
                TabView(selection: $selectedImageIndex) {
                    ForEach(0..<imageUrls.count, id: \.self) { index in
                        WebImage(url: URL(string: imageUrls[index].imageUrl()))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contextMenu {
                                Button(action: {
                                    copyImage(url: imageUrls[index].imageUrl())
                                }) {
                                    Text("Copy Image")
                                    Image(systemName: "doc.on.doc.fill")
                                }
                                Button(action: {
                                    saveImage(url: imageUrls[index].imageUrl())
                                }) {
                                    Text("Save Image")
                                    Image(systemName: "square.and.arrow.down")
                                }
                            }
                            .tag(index)
                    }
                }
                .tabViewStyle(tabViewStyleForCurrentPlatform()) // 实现分页滑动
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray)
                HStack {
                    Button(action: {
                        if selectedImageIndex > 0 {
                            withAnimation {
                                selectedImageIndex -= 1
                            }
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if selectedImageIndex < imageUrls.count - 1 {
                            withAnimation {
                                selectedImageIndex += 1
                            }
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                    }
                }
                .font(.system(size: 60))
                .foregroundColor(Color.white)
                .buttonStyle(.plain)
                .padding(.horizontal, 100)
                if isLoading {
                    ZStack {
                        ProgressView()
                            .controlSize(.extraLarge)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onTapGesture {
            showPreview = false
        }
    }
    
    func tabViewStyleForCurrentPlatform() -> some TabViewStyle {
#if os(iOS)
        return PageTabViewStyle(indexDisplayMode: .automatic)
#elseif os(macOS)
        return DefaultTabViewStyle() // macOS 下使用的样式
#endif
    }
    
    // 键盘事件处理
    func handleKeyDown(event: NSEvent) {
        switch event.keyCode {
        case 123: // 左箭头键
            if selectedImageIndex > 0 {
                selectedImageIndex -= 1
            }
        case 124: // 右箭头键
            if selectedImageIndex < imageUrls.count - 1 {
                selectedImageIndex += 1
            }
        default:
            break
        }
    }
    
    func copyImage(url: String) {
        copyCallBackAction(url)
    }
    
    // 保存图片方法
    func saveImage(url: String) {
        guard let imageUrl = URL(string: url) else { return }
        isLoading = true
#if os(iOS)
        SDWebImageDownloader.shared.downloadImage(with: imageUrl) { (image, data, error, finished) in
            if let image = image, finished {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
#elseif os(macOS)
        SDWebImageDownloader.shared.downloadImage(with: imageUrl) { (image, data, error, finished) in
            isLoading = false
            if let imageData = data, finished {
                let panel = NSSavePanel()
                panel.title = "Save Image"
                panel.nameFieldStringValue = imageUrl.lastPathComponent
                panel.allowedContentTypes = [.png, .jpeg]
                panel.begin { (result) in
                    if result == .OK, let url = panel.url {
                        try? imageData.write(to: url)
                    }
                }
            }
        }
#endif
    }
}

//#Preview {
//    NoteImageBrowserPreViewImagesView()
//}
