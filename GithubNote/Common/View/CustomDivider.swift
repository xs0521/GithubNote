//
//  CustomDivider.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import SwiftUI

struct CustomDivider: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.init(hex: "#000000") : Color.init(hex: "#DCDCDC"))
            .frame(height: 0.5)
            .edgesIgnoringSafeArea(.horizontal)
    }
}
