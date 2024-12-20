//
//  PrivateTagView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/22.
//

import SwiftUI

struct PrivateTagView: View {
    
    var body: some View {
        Text("private".language())
            .foregroundColor([Color.black, Color.white])
            .font(.system(size: 6))
            .padding(EdgeInsets(top: 2, leading: 3, bottom: 2, trailing: 3))
            .background([Color.init(hex: "#DFE1E6"), Color.gray])
            .cornerRadius(5)
    }
}

#Preview {
    PrivateTagView()
}
