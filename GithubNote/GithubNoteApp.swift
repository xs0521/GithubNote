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
    
    private func loginOutAction() -> Void {
        Account.reset()
        logined = Account.enble
        willLoginOut = false
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
                            loginOutAction()
                        })
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logoutNotification), perform: { _ in
                    willLoginOut = true
                })
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logoutForceNotification), perform: { _ in
                    loginOutAction()
                })
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
            } else {
                GitHubLoginView(loginCallBack: {
                    logined = Account.enble
                })
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
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
                    openWindow(id: AppConst.settingWindowName)
                }
                .keyboardShortcut(",", modifiers: [.command]) // 添加快捷键
            }
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
        }
        
        
        WindowGroup(AppConst.settingWindowName,
                    id: AppConst.settingWindowName,
                    for: String.self) { $value in
            SettingsView(isLogined: $logined)
        }
                    .windowResizability(.contentSize)
                    .windowStyle(HiddenTitleBarWindowStyle())
    }
}


