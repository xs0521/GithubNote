//
//  GithubNoteApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import SwiftUI
import SwiftUIFlux

let store = Store<AppState>(reducer: appStateReducer,
                            middleware: [loggingMiddleware],
                            state: AppState())

let repoStore = RepoModelStore(select: AppUserDefaults.repo)
let issueStore = IssueModelStore(select: AppUserDefaults.issue)



@main
struct GithubNoteApp: App {
    
    @State var logined = UserManager.shared.isLogin()
    @State var willLoginOut: Bool = false
    @State private var importing: Bool? = true
    @State var isSetting: Bool = false
    
    @Environment(\.openWindow) private var openWindow
    
    init() {
        let _ = LaunchApp.shared
    }
    
    private func loginOutAction() -> Void {
        AppUserDefaults.reset()
        UserManager.shared.save(nil)
        logined = UserManager.shared.isLogin()
        willLoginOut = false
    }
    
    var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                VStack {
                    if logined {
                        ZStack {
                            NoteContentView()
                                .environmentObject(repoStore)
                                .environmentObject(issueStore)
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
        #if !MOBILE
                            NSWindow.allowsAutomaticWindowTabbing = false
        #endif
                            
                        }
                    } else {
                        GitHubLoginView(loginCallBack: {
                            logined = UserManager.shared.isLogin()
                        })
                        .onAppear {
        #if !MOBILE
                            NSWindow.allowsAutomaticWindowTabbing = false
        #endif
                        }
                    }
                }
            }
        }
        .defaultSize(width: AppConst.defaultWidth, height: AppConst.defaultHeight)
        .windowResizability(.contentSize)
#if !MOBILE
        .windowStyle(HiddenTitleBarWindowStyle())
#endif
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
#if !MOBILE
                    .windowStyle(HiddenTitleBarWindowStyle())
#endif
    }
}


