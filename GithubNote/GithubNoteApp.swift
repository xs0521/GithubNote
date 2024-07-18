//
//  GithubNoteApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import SwiftUI
import SDWebImage

@main
struct GithubNoteApp: App {
    
    @State var logined: Bool = Account.enble
    @State var willLoginOut: Bool = false
    @State private var importing: Bool? = true
    
    var body: some Scene {
        WindowGroup {
            if !logined {
                LoginView {
                    logined = Account.enble
                }
            }
            if logined {
                ZStack {
                    NoteContentView()
                        .onAppear(perform: {
                    SDWebImageDownloader.shared.setValue("Bearer \(Account.accessToken)", forHTTPHeaderField: "Authorization")
                        })
                    if willLoginOut {
                        LoginOutView(cancelCallBack: {
                            willLoginOut = false
                        }, loginOutCallBack: {
                            Account.reset()
                            logined = Account.enble
                            willLoginOut = false
                        })
                    }
                }
            }
        }
        .defaultSize(width: AppConst.defaultWidth, height: AppConst.defaultHeight)
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            if logined {
                CommandMenu("Account") {
                    Button("Logout") {
                        "Logout".p()
                        willLoginOut = true
                    }
                }
            }
        }
    }
}
