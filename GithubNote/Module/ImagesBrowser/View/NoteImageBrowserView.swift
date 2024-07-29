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
    @Binding var progressValue: Double
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @Binding var showLoading: Bool
    @Binding var syncImages: Bool
    
    @State private var showProgress = false
    
    @State var data: [GithubImage] = []

    var body: some View {
        ZStack {
            NoteImageBrowserImagesView(showImageBrowser: $showImageBrowser,
                                       data: $data,
                                       showToast: $showToast,
                                       toastMessage: $toastMessage,
                                       showLoading: $showLoading)
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
                    progressValue = 0.0
                    showImageBrowser = false
                }
            
            if showProgress {
                VStack {
                    Spacer()
                    ProgressView(value: progressValue, total: 1.0)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        .tint(.init(light: Color.gray, dark: Color.white))
                }
            }
        }
        .onChange(of: progressValue, { oldValue, newValue in
            showProgress = newValue > 0
            if newValue >= 1.0 {
                toastMessage = "success"
                showToast = true
            }
        })
        .onChange(of: syncImages) { oldValue, newValue in
            requestImagesData(false, false)
        }
        .onAppear(perform: {
            progressValue = 0.0
        })
        .toast(isPresenting: $showToast, duration: 2.0, tapToDismiss: true){
            AlertToast(displayMode: .hud, type: .systemImage("party.popper", .primary), title: toastMessage)
        }
        .toast(isPresenting: $showLoading){
            AlertToast(type: .loading, title: nil, subTitle: nil)
        }
    }
    
    func requestImagesData(_ writeCache: Bool = true, _ readCache: Bool = true) -> Void {
        
        showLoading = true
        Networking<GithubImage>().request(API.repoImages, writeCache: writeCache, readCache: readCache) { data, cache, code in
            if code == MessageCode.notFound.rawValue {
                self.data.removeAll()
                requestCreateImageDir(completion: {
                    showLoading = false
                })
                return
            }
            showLoading = false
            guard let list = data else {
                self.data.removeAll()
                return
            }
            let images = list.filter({$0.path.isImage()})
            self.data = images
        }
    }
    
    func requestCreateImageDir(completion: @escaping CommonCallBack) -> Void {
        
        Networking<PushCommitModel>().request(API.createImagesDirectory, writeCache: false, readCache: false) { data, cache, code in
            completion()
            if code != MessageCode.createSuccess.rawValue {
                return
            }
        }
        
    }
}


