//
//  NoteTaskView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/9.
//

import SwiftUI

struct NoteTaskView: View {
    
    @Binding var task: Comment
    @Binding var selectedTask: Comment?
    @Binding var inspectorIsShown: Bool
    
    var body: some View {
        HStack {
//            Image(systemName: task.isCompleted ? "largecircle.fill.circle" : "circle")
//                .onTapGesture {
//                    task.isCompleted.toggle()
//                }
            
//            TextField("New Task", text: $task.title)
//                .textFieldStyle(.plain)
            
            Text(task.body.toTitle())
            
            Button(action: {
                inspectorIsShown = true
                selectedTask = task
            }, label: {
                Text("More")
            })
        }
    }
}
