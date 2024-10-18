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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            NoteImageBrowserImagesView(showImageBrowser: $showImageBrowser,
                                       showToast: $showToast,
                                       toastMessage: $toastMessage,
                                       showLoading: $showLoading)
            .background(colorScheme == .dark ? Color.init(hex: "#292929") : Color.init(hex: "#ECECEB"))
            .onTapGesture {
                progressValue = 0.0
                showImageBrowser = false
            }
            
//            if showProgress {
//                VStack {
//                    Spacer()
//                    ProgressView(value: progressValue, total: 1.0)
//                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
//                        .tint(colorScheme == .dark ? Color.white : Color.gray)
//                }
//            }
        }
        .onChange(of: progressValue, { oldValue, newValue in
//            showProgress = newValue > 0
//            if newValue >= 1.0 {
//                toastMessage = "success"
//                showToast = true
//            }
        })
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
}


