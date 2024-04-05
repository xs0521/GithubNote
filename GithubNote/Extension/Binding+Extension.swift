//
//  Binding+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/26.
//

import SwiftUI


extension Binding {
    func didSet(_ didSet: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: { wrappedValue },
                set: { newValue in
                    self.wrappedValue = newValue
                    didSet(newValue)
                })
    }
}
