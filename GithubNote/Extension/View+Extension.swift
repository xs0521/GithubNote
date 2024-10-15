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


public extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> TupleView<(Self?, Content?)> {
        if conditional {
            return TupleView((nil, content(self)))
        } else {
            return TupleView((self, nil))
        }
    }
}
