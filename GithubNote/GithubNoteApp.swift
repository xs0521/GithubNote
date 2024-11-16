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
let commentStore = CommentModelStore(select: AppUserDefaults.comment)
let writeStore = WriteModelStore()
let appStore = AppModelStore()
let imagesStore = ImagesModelStore()

@main
struct GithubNoteApp: App {
    
    @State var logined = UserManager.shared.isLogin()
    @State private var importing: Bool? = true
    @State var isSetting: Bool = false
    @State private var isSettingsWindowOpen = false
    @State private var showAlert = false
    
    @StateObject private var alertStore = AlertModelStore()
    
    @Environment(\.openWindow) private var openWindow
    
    init() {
        let _ = LaunchApp.shared
    }
    
    private func loginOutAction() -> Void {
        AppUserDefaults.reset()
        UserManager.shared.save(nil)
        logined = UserManager.shared.isLogin()
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
                                .environmentObject(commentStore)
                                .environmentObject(writeStore)
                                .environmentObject(appStore)
                                .environmentObject(imagesStore)
                                .environmentObject(alertStore)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logoutForceNotification), perform: { _ in
                            loginOutAction()
                        })
                        .onAppear {
        #if !MOBILE
                            NSWindow.allowsAutomaticWindowTabbing = false
        #endif
                            store.dispatch(action: ReposActions.FetchList(readCache: true, completion: nil))
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
                .customAlert(isVisible: $alertStore.isVisible, 
                             title: alertStore.title,
                             message: alertStore.message, onConfirm: {
                    alertStore.onConfirm?()
                }, onCancel: {
                    alertStore.onCancel?()
                })
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
                    toggleSettingsWindow()
                }
                .keyboardShortcut(",", modifiers: [.command]) // 添加快捷键
            }
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
            // 添加自定义命令到 Edit 菜单中
            CommandGroup(after: CommandGroupPlacement.pasteboard) {
                
                ForEach(KeyboardType.allCases, id: \.self) { keyboardType in
                    Button(keyboardType.title) {
                        KeyboardManager.sendKeyPressEvent(characters: keyboardType.character, modifiers: .command)
                    }
                    .keyboardShortcut(KeyEquivalent(keyboardType.character.first!), modifiers: [.command])
                }
            }
        }
        
        WindowGroup(AppConst.settingWindowName,
                    id: AppConst.settingWindowName,
                    for: String.self) { $value in
            SettingsView(isLogined: $logined, logoutCallBack: {
                loginOutAction()
            })
                .onAppear {
                    isSettingsWindowOpen = true
                }
                .onDisappear {
                    isSettingsWindowOpen = false
                }
        }
                    .windowResizability(.contentSize)
#if !MOBILE
                    .windowStyle(HiddenTitleBarWindowStyle())
#endif
    }
    
    private func toggleSettingsWindow() {
        if isSettingsWindowOpen {
            bringSettingsWindowToFront()
        } else {
            openWindow(id: AppConst.settingWindowName)
        }
    }
    
    private func bringSettingsWindowToFront() {
        // 查找包含指定标识符的窗口
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.contains(AppConst.settingWindowName) == true }) {
            window.orderFrontRegardless() // 强制将窗口显示到最前面
        }
    }
    
    
}


