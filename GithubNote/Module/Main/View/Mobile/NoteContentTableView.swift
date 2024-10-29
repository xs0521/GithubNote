//
//  NoteContentTableView.swift
//  GithubNoteMobile
//
//  Created by xs0521 on 2024/10/23.
//

import SwiftUI

struct NoteContentTableView: View {
    
    @State private var reposGroups: [RepoModel] = [RepoModel]()
    @State private var repoPage = 1
    @Binding var selectionRepo: RepoModel?
    
    @State private var issueGroups = [Issue]()
    @State private var issuePage = 1
    @Binding var selectionIssue: Issue?
    
    @Binding var commentGroups: [Comment]
    @State private var commentPage = 1
    @Binding var selectionComment: Comment?
    
    @State private var selectedTab = Tab.notes
    @State private var showReposView: Bool = false
    
    enum Tab: Int {
        case notes, folders
    }
    
    func tabbarItem(text: String, image: String) -> some View {
        VStack {
            Image(systemName: image)
                .imageScale(.small)
            Text(text)
        }
        .foregroundColor(.primary)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NoteCommentsView(commentGroups: $commentGroups,
                             selectionComment: $selectionComment,
                             selectionIssue: $selectionIssue)
            .tabItem{
                self.tabbarItem(text: "Note", image: "note")
            }.tag(Tab.notes)
            NoteIssuesView()
            .tabItem{
                self.tabbarItem(text: "NoteBook", image: "menucard")
            }.tag(Tab.folders)
        }
    }
}
