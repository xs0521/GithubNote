//
//  NoteSidebarView.swift
//  GithubNote
//
//  Created by luoshuai on 2024/7/9.
//

import SwiftUI

struct NoteSidebarView: View {
    
    @Binding var userCreatedGroups: [Repo]
    @Binding var reposGroups: [Repo]
    @Binding var selection: Repo?
    
    @Binding var issueGroups: [Issue]
    @Binding var selectionIssue: Issue?
    
    var body: some View {
        VStack {
            List(selection: $selectionIssue) {
                Section("Issues") {
                    ForEach(issueGroups) { selection in
                        Label(selection.title ?? "unknow",
                              systemImage: "star")
                        .tag(selection)
                    }
                }
            }
            Spacer()
            HStack {
                Text("Repos")
                    .padding(.leading, 16)
                Spacer()
            }
            List(selection: $selection) {
                ForEach(reposGroups) { selection in
                    Label(selection.name ?? "unknow",
                          systemImage: "star")
                    .tag(selection)
                }
            }
            .frame(maxHeight: 200)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                let newGroup = Repo()
                userCreatedGroups.append(newGroup)
            }, label: {
                Label("Add Issue", systemImage: "plus.circle")
            })
            .buttonStyle(.borderless)
            .foregroundColor(.accentColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .keyboardShortcut(/*@START_MENU_TOKEN@*/KeyEquivalent("a")/*@END_MENU_TOKEN@*/, modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
        }
        
    }
}
