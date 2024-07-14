//
//  NoteTaskListView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI

struct NoteTaskListView: View {
    
    let title: String
    @Binding var tasks: [Comment]
    @State private var selectedTask: Comment? = nil
    
    @State private var inspectorIsShown: Bool = false
    
    var body: some View {
        List($tasks) { $task in
            NoteTaskView(task: $task,
                     selectedTask: $selectedTask,
                     inspectorIsShown: $inspectorIsShown)
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    tasks.append(Comment())
                } label: {
                    Label("Add New Task", systemImage: "plus")
                }
                
                Button {
                    inspectorIsShown.toggle()
                } label: {
                    Label("Show inspector", systemImage: "sidebar.right")
                }
            }
           
        }
        .inspector(isPresented: $inspectorIsShown) {
            Group {
                if let selectedTask {
                    Text(selectedTask.body.toTitle()).font(.title)
                } else {
                    Text("nothing selected")
                }
            }
            .frame(minWidth: 100, maxWidth: .infinity)
        }
    }
}
