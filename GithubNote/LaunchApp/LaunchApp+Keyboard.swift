//
//  LaunchApp+Keyboard.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/16.
//

import Foundation
import AppKit

extension LaunchApp {
    
    func configKeyboard() -> Void {
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
    
    //键盘抬起：(含)普通按键Key——可一直输入的Key按键
    private func keyUp(with event: NSEvent) {
        let _ = event.keyCode    //类型：CUnsignedShort即UInt16
//        "#keyboard# keyUp-> keyCode:\(keyCode)   event.characters:\(event.characters as Any)".logI()
//        NotificationCenter.default.post(name: Notification.Name.keyboard, object: event)
        
    }
    
    //键盘按下：(含)普通按键Key——可一直输入的Key按键
    private func keyDown(with event: NSEvent) {
        let _ = event.keyCode    //类型：CUnsignedShort即UInt16
//        "#keyboard# keyCode:\(keyCode)   event.characters:\(event.characters as Any)".logI()
    }
    
    /// 按键变化：(仅有)特殊的功能控制键Key——shift、control、option、option及相互组合
    private func flagsChanged(with event: NSEvent) {
//        print("flagsChanged->", event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask))
    }
}
