//
//  ToastManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import Foundation
import AlertToast

enum ToastScene {
    case home
    case setting
}

struct ToastItem {
    let title: String
    let scene: ToastScene
    let mode: AlertToast.DisplayMode
    let type: AlertToast.AlertType
    
    init(title: String, scene: ToastScene, mode: AlertToast.DisplayMode, type: AlertToast.AlertType) {
        self.title = title
        self.scene = scene
        self.mode = mode
        self.type = type
    }
}

class ToastManager {
    
    var homeCallBack: CommonTCallBack<ToastItem>?
    var settingCallBack: CommonTCallBack<ToastItem>?
    static let shared = ToastManager()
    
    private let kIconSuccess = "party.popper"
    private let kIconFail = "xmark.app.fill"
    
    func show(_ content: String) -> Void {
        show(ToastItem(title: content, scene: .home, mode: .hud, type: .regular))
    }
    
    func showSetting(_ content: String) -> Void {
        show(ToastItem(title: content, scene: .setting, mode: .hud, type: .regular))
    }
    
    func showSuccess(_ content: String) -> Void {
        show(ToastItem(title: content, scene: .home, mode: .hud, type: .systemImage(kIconSuccess, .primary)))
    }
    
    func showFail(_ content: String) -> Void {
        show(ToastItem(title: content, scene: .home, mode: .hud, type: .systemImage(kIconFail, .primary)))
    }
    
    func showSettingSuccess(_ content: String) -> Void {
        show(ToastItem(title: content, scene: .setting, mode: .hud, type: .systemImage(kIconSuccess, .primary)))
    }
    
    func showSettingFail(_ content: String) -> Void {
        show(ToastItem(title: content, scene: .setting, mode: .hud, type: .systemImage(kIconFail, .primary)))
    }
    
    func show(_ item: ToastItem) -> Void {
        if item.title.isEmpty {
            return
        }
        switch item.scene {
        case .home:
            homeCallBack?(item)
        case .setting:
            settingCallBack?(item)
        }
    }
}
