//
//  NoteImageBrowserImagesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/29.
//

import SwiftUI
import SDWebImageSwiftUI
import AlertToast
import SwiftUIFlux

struct NoteImageBrowserImagesView: ConnectedView {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var appStore: AppModelStore
    @EnvironmentObject var imagesStore: ImagesModelStore
    
    @State private var isTapEmptyLoading: Bool = false
    
    static let size = CGSizeMake(100, 100)
    
    let adaptiveColumn = [
        GridItem(.adaptive(minimum: NoteImageBrowserImagesView.size.width, maximum: NoteImageBrowserImagesView.size.width))
    ]
    
    struct Props {
        let isPreview: Bool
        let list: [GithubImage]
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        "#ImageBrowser# map isPreview \(state.imagesState.isPreview) list \(state.imagesState.list.count)".logI()
        return Props(isPreview: state.imagesState.isPreview,
                     list: state.imagesState.list)
    }
    
    func body(props: Props) -> some View {
        ZStack {
            ScrollView (showsIndicators: false) {
                if props.list.isEmpty {
                    if isTapEmptyLoading {
                        ProgressView()
                            .controlSize(.mini)
                            .frame(width: 25, height: 25)
                    } else {
                        NoteEmptyView(tapCallBack: {
                            isTapEmptyLoading = true
                            store.dispatch(action: ImagesActions.FetchList(readCache: false, completion: { finish in
                                isTapEmptyLoading = false
                            }))
                        })
                        .padding(.top, 100)
                    }
                } else {
                    LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                        ForEach(props.list, id: \.self) { item in
                            Button(action: {
                                imagesStore.currentUrl = item.imageUrl()
                                imagesStore.currentIndex = props.list.firstIndex(of: item) ?? 0
                                store.dispatch(action: ImagesActions.Preview(on: true))
                            }, label: {
                                ZStack {
                                    Color.init(hex: "#D2D2D3")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .opacity(0.3)
                                    WebImage(url: URL(string: item.imageUrl())) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Rectangle().foregroundColor(.gray)
                                        }
                                        .indicator(.activity) // Activity Indicator
                                        .transition(.fade(duration: 0.5)) // Fade Transition with duration
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            })
                            .frame(width: NoteImageBrowserImagesView.size.width, height: NoteImageBrowserImagesView.size.height)
                            .cornerRadius(4)
                            .transition(.fade(duration: 0.3))
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(action: {
                                    store.dispatch(action: ImagesActions.Copy(url: item.imageUrl()))
                                }) {
                                    Text("copy_image".language())
                                    CustomImage(systemName: "doc.on.doc.fill")
                                }
                                Button(action: {
                                    appStore.isLoadingVisible = true
                                    store.dispatch(action: ImagesActions.Delete(item: item, completion: { success in
                                        appStore.isLoadingVisible = false
                                        if success {
                                            let list = props.list.filter({$0.identifier != item.identifier})
                                            store.dispatch(action: ImagesActions.SetList(list: list))
                                        }
                                    }))
                                }) {
                                    Text("delete_image".language())
                                    CustomImage(systemName: "xmark.bin.circle.fill")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 160)
            .padding(.horizontal, 80)
            .background(Color.clear)
            .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
            if props.isPreview {
                NoteImageBrowserPreViewImagesView()
            } else {
                if let name = AppUserDefaults.repo?.name, !name.isEmpty {
                    VStack {
                        Text("\(name.uppercased())")
                            .font(.system(.largeTitle))
                        Spacer()
                    }
                }
            }
        }
        .onAppear(perform: {
            store.dispatch(action: ImagesActions.FetchList(readCache: true, completion: { _ in
                
            }))
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.syncNetImagesNotification), perform: { _ in
            appStore.isLoadingVisible = true
            store.dispatch(action: ImagesActions.FetchList(readCache: false, completion: { finish in
                appStore.isLoadingVisible = false
            }))
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.appendImagesNotification), perform: { _ in
            appStore.isLoadingVisible = true
            store.dispatch(action: ImagesActions.FetchList(readCache: true, completion: { finish in
                appStore.isLoadingVisible = false
            }))
        })
    }
}
