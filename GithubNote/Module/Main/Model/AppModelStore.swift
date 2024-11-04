//
//  AppModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import Combine
import SwiftUI

final class AppModelStore: ObservableObject {
    
    @Published var isToastVisible: Bool = false
    @Published var isLoadingVisible: Bool = false
    @Published var toastMessage: String = ""
    @Published var item: ToastItem?
}
