//
//  CustomImage.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/7.
//

import SwiftUI

struct CustomImage: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .opacity(0.7)
    }
}
