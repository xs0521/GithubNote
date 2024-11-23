//
//  CustomBackground.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/23.
//

import Foundation
import SwiftUI

private struct ColorViewBackgroundModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let lightColor: Color
    let darkColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? darkColor : lightColor)
    }
}

private struct ColorViewFontModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let lightColor: Color
    let darkColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(colorScheme == .dark ? darkColor : lightColor)
    }
}

//private struct ColorViewFillModifier<content: Shape>: ViewModifier {
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    let lightColor: Color
//    let darkColor: Color
//    
//    func body(content: Content) -> some View {
//        content
//            .fill
//    }
//}

extension View {
    func background(_ colors: [Color]) -> some View {
        self.modifier(ColorViewBackgroundModifier(lightColor: colors.last!, darkColor: colors.first!))
    }
}

extension View {
    func foregroundColor(_ colors: [Color]) -> some View {
        self.modifier(ColorViewFontModifier(lightColor: colors.last!, darkColor: colors.first!))
    }
}

//extension Shape {
//    
//    public func fill(_ colors: [Color]) -> some View {
//        self.modifier(ColorViewFillModifier<<#content: Shape#>>(lightColor: colors.first!, darkColor: colors.last!))
//    }
//}
