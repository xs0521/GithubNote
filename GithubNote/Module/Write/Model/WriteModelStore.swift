//
//  WriteModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import Combine
import SwiftUI

final class WriteModelStore: ObservableObject {
    
    @Published var markdownString: String? {
        didSet {
            
        }
    }
}
