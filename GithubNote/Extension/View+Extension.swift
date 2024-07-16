//
//  View+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/16.
//

import SwiftUI

public extension View {
    func transparentScrolling() -> some View {
        scrollContentBackground(.hidden)
    }
}
