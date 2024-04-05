//
//  GithubNoteApp.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import SwiftUI

@main
struct GithubNoteApp: App {
    
    @State var logined: Bool = Account.enble
    
    var body: some Scene {
        WindowGroup {
            if !logined {
                LoginView {
                    logined = Account.enble
                }
            }
            if logined {
                ContentView()
                    .frame(minWidth: 1000, maxWidth: 1600, minHeight: 800, maxHeight: 1000)
            }
        }
        .defaultSize(width: 800, height: 600)
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
