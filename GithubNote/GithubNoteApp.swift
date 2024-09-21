//
//  GithubNoteApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import SwiftUI


@main
struct GithubNoteApp: App {
    
    @State var logined: Bool = Account.enble
    @State var willLoginOut: Bool = false
    @State private var importing: Bool? = true
    @State var isSetting: Bool = false
    
    @Environment(\.openWindow) private var openWindow
    
    init() {
        let _ = LaunchApp.shared
    }
    
    var body: some Scene {
        WindowGroup {
            if logined {
                ZStack {
                    NoteContentView()
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
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logoutNotification), perform: { _ in
                    willLoginOut = true
                })
            } else {
                LoginView {
                    logined = Account.enble
                }
            }
        }
        .defaultSize(width: AppConst.defaultWidth, height: AppConst.defaultHeight)
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    // 打开设置窗口
                    openWindow(id: "WindowGroup1")
                }
                .keyboardShortcut(",", modifiers: [.command]) // 添加快捷键
            }
        }
        
        
        WindowGroup("WindowGroup1", id: "WindowGroup1", for: String.self) { $value in
            SettingsView()
        }
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}


