//
//  KeyCaptureViewRepresentable.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/19.
//

import SwiftUI
import AppKit

// 自定义 NSView 来捕获键盘事件
class KeyCaptureView: NSView {
    var onKeyDown: ((_ event: NSEvent) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        onKeyDown?(event) // 触发回调，传递键盘事件
    }
}

// 使用 NSViewRepresentable 将 NSView 包装为 SwiftUI 组件
struct KeyCaptureViewRepresentable: NSViewRepresentable {
    var onKeyDown: ((_ event: NSEvent) -> Void)?

    func makeNSView(context: Context) -> NSView {
        let view = KeyCaptureView()
        view.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

