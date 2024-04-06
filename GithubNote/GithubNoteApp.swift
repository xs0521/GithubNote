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
            }
        }
        .defaultSize(width: AppConst.defaultWidth, height: AppConst.defaultHeight)
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
