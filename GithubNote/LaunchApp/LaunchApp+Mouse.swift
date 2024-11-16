//
//  LaunchApp+Mouse.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/16.
//

import Foundation
import AppKit

extension LaunchApp {
    
    func configMouse() -> Void {
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
            self.handleMouseMoved(event)
            return event
        }
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
            NotificationCenter.default.post(name: Notification.Name.mouse, object: true)
        } else {
            if !isHoverArea {
                return
            }
            isHoverArea = false
            "#mouse# level".logI()
            NotificationCenter.default.post(name: Notification.Name.mouse, object: false)
        }
    }
}
