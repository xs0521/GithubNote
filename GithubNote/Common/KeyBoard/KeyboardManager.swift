//
//  KeyboardManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/15.
//

import Foundation
import AppKit

enum KeyboardType: CaseIterable {
    
    case insertImage
    case OriginalText
    case WorkSpace
    
    var character: String {
        switch self {
        case .insertImage:
            return "p"
        case .OriginalText:
            return "/"
        case .WorkSpace:
            return "r"
        }
    }
    
    var title: String {
        switch self {
        case .insertImage:
            return "insert_image".language()
        case .OriginalText:
            return "original_text".language()
        case .WorkSpace:
            return "workspace".language()
        }
    }
    
    struct keyCode {
        static let ESC = 53
    }
}

class KeyboardManager {
    
    static func sendKeyPressEvent(characters: String, modifiers: NSEvent.ModifierFlags) {
        guard let window = NSApp.keyWindow else {
            "No active window to send the event.".logE()
            return
        }

        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifiers,
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber,
            context: nil,
            characters: characters,
            charactersIgnoringModifiers: "",
            isARepeat: false,
            keyCode: 0
        )
        
        NotificationCenter.default.post(name: Notification.Name.keyboard, object: event)
    }
}
