//
//  LaunchApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import Foundation
import AppKit

private let SETUPLIST: [Setupable.Type] = [LogManager.self,
                                           WebServerManager.self]

private let SETUPLISTLOGIN: [Setupable.Type] = [SDWebImageDownloaderSetup.self,
                                                CacheManager.self]

class LaunchApp {
    static let shared = LaunchApp()
    private var isHoverArea = false
    
    init() {
        SETUPLIST.forEach({$0.setup()})
        if UserManager.shared.isLogin() {
            loginSetup()
        }
        
        //开启对键盘的监听
        configKeyboard()
        configMouse()
    }
    
    func loginSetup() -> Void {
        SETUPLISTLOGIN.forEach({$0.setup()})
    }
    
    private func configKeyboard() -> Void {
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyUp) {
            self.keyUp(with: $0)
            return $0
        }
    }
    
    private func configMouse() -> Void {
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
            self.handleMouseMoved(event)
            return event
        }
    }
    
    //键盘抬起：(含)普通按键Key——可一直输入的Key按键
    private func keyUp(with event: NSEvent) {
        let keyCode = event.keyCode    //类型：CUnsignedShort即UInt16
//        "#keyboard# keyUp-> keyCode:\(keyCode)   event.characters:\(event.characters as Any)".logI()
        NotificationCenter.default.post(name: Notification.Name.keyboard, object: event)
        
    }
    
    //键盘按下：(含)普通按键Key——可一直输入的Key按键
    private func keyDown(with event: NSEvent) {
        let keyCode = event.keyCode    //类型：CUnsignedShort即UInt16
//        "#keyboard# keyCode:\(keyCode)   event.characters:\(event.characters as Any)".logI()
    }
    
    /// 按键变化：(仅有)特殊的功能控制键Key——shift、control、option、option及相互组合
    private func flagsChanged(with event: NSEvent) {
//        print("flagsChanged->", event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask))
    }
    
    private func handleMouseMoved(_ event: NSEvent) {
        guard let window = NSApp.keyWindow else { return }
        
        // 获取鼠标在窗口中的位置
        let mouseLocation = window.mouseLocationOutsideOfEventStream
        
        // 判断鼠标是否在距离顶部 100 像素的范围内
        if mouseLocation.y >= window.frame.height - 100 {
            if isHoverArea {
                return
            }
            isHoverArea = true
            "#mouse# enter".logI()
            NotificationCenter.default.post(name: NSNotification.Name.mouse, object: true)
        } else {
            if !isHoverArea {
                return
            }
            isHoverArea = false
            "#mouse# level".logI()
            NotificationCenter.default.post(name: NSNotification.Name.mouse, object: false)
        }
    }
}
