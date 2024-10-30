//
//  NoteImageBrowserPreViewImagesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/19.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUIFlux

struct NoteImageBrowserPreViewImagesView: ConnectedView {
    
    @EnvironmentObject var imagesStore: ImagesModelStore
    
//    var copyCallBackAction: CommonTCallBack<String>
    
    @State private var isLoading: Bool = false
    
    struct Props {
        let isPreview: Bool?
        let list: [GithubImage]
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isPreview: state.imagesState.isPreview,
                     list: state.imagesState.list)
    }
    
    func body(props: Props) -> some View {
        VStack {
            ZStack {
                // 添加 NSViewRepresentable 以捕获键盘事件
#if !MOBILE
                KeyCaptureViewRepresentable { event in
                    handleKeyDown(event: event, props: props)
                }
                .frame(width: 0, height: 0)
#endif
                TabView(selection: $imagesStore.currentIndex) {
                    ForEach(0..<props.list.count, id: \.self) { index in
                        WebImage(url: URL(string: props.list[index].imageUrl()))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contextMenu {
                                Button(action: {
                                    copyImage(url: props.list[index].imageUrl())
                                }) {
                                    Text("Copy Image")
                                    Image(systemName: "doc.on.doc.fill")
                                }
                                Button(action: {
                                    saveImage(url: props.list[index].imageUrl())
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
                        if imagesStore.currentIndex > 0 {
                            withAnimation {
                                imagesStore.currentIndex -= 1
                            }
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if imagesStore.currentIndex < props.list.count - 1 {
                            withAnimation {
                                imagesStore.currentIndex += 1
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
            store.dispatch(action: ImagesActions.Preview(on: false))
        }
    }
    
    func tabViewStyleForCurrentPlatform() -> some TabViewStyle {
#if os(iOS)
        return PageTabViewStyle(indexDisplayMode: .automatic)
#elseif os(macOS)
        return DefaultTabViewStyle() // macOS 下使用的样式
#endif
    }
    
#if !MOBILE
    // 键盘事件处理
    func handleKeyDown(event: NSEvent, props: Props) {
        switch event.keyCode {
        case 123: // 左箭头键
            if imagesStore.currentIndex > 0 {
                imagesStore.currentIndex -= 1
            }
        case 124: // 右箭头键
            if imagesStore.currentIndex < props.list.count - 1 {
                imagesStore.currentIndex += 1
            }
        default:
            break
        }
    }
#endif
    
    func copyImage(url: String) {
//        copyCallBackAction(url)
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
