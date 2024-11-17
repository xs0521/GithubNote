//
//  AlertManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/15.
//

import Foundation
import Combine
import SwiftUI

final class AlertModelStore: ObservableObject {
    
    @Published var isVisible: Bool = false
    @Published private(set) var title: String = ""
    @Published private(set) var message: String = ""
    
    private(set) var onConfirm: (() -> Void)?
    private(set) var onCancel: (() -> Void)?
    private(set) var autoDismiss: Bool = true
    
    func show(_ title: String = "alert".language(), desc message: String, _ autoDismiss: Bool = true, onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) -> Void {
        self.title = title
        self.message = message
        self.autoDismiss = autoDismiss
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.isVisible = true
    }
}


