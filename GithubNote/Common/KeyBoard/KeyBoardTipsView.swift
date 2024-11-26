//
//  KeyBoardTipsView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/26.
//

import SwiftUI

struct KeyBoardTipsView: View {
    var body: some View {
        VStack {
            VStack {
                Text("command + r".uppercased())
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .foregroundStyle(Color.white)
                Text("select_workspace_tips".language())
                    .foregroundStyle(Color.white)
                    .padding(.top, 1)
            }
            .frame(width: 300, height: 200)
            .background(Color.black.opacity(0.8))
            .cornerRadius(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack {
        KeyBoardTipsView()
    }
    .frame(width: 400, height: 300)

}

