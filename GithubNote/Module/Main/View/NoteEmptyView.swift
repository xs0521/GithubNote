//
//  NoteEmptyView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/23.
//

import SwiftUI

enum NoteEmptyType {
    case download
    case coffee
    
    var imageName: String {
        switch self {
        case .download:
            return "arrow.down.circle"
        case .coffee:
            return "cup.and.saucer"
        }
    }
    
}

struct NoteEmptyView: View {
    
    var type: NoteEmptyType = .download
    var tapCallBack: CommonCallBack
    
    var body: some View {
        CustomImage(systemName: type.imageName)
            .font(.system(size: 25))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                "#NE# tap".logI()
                tapCallBack()
            }
    }
}
