//
//  NoteReposView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/22.
//

import SwiftUI

struct NoteReposView: View {
    
    @Binding var reposGroups: [RepoModel]
    @Binding var selectionRepo: RepoModel?
    
    var body: some View {
        List(selection: $selectionRepo) {
            ForEach(reposGroups) { selection in
                VStack {
                    HStack {
                        Label(title: {
                            Text(selection.name ?? "unknow")
                        }, icon: {
                            Image(systemName: "star")
                                .foregroundStyle(Color.primary)
                        })
                        .tag(selection)
                        Spacer()
                    }
                }
            }
        }
        .background(Color.background)
    }
}

//#Preview {
//    NoteReposView()
//}
