//
//  ImagesModelStore.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/31.
//

import Foundation
import Combine
import SwiftUI

final class ImagesModelStore: ObservableObject {
    
    @Published var currentUrl: String = ""
    
    @Published var currentIndex: Int = 0 {
        didSet {
            
        }
    }
}
