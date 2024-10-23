//
//  SettingsView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import SwiftUI
#if MOBILE
import UIKit
#else
import AppKit
#endif
import AlertToast

enum SettingType {
    case account
    case feedback
    case help
    case logout
    case log
    
    var title: String {
        switch self {
        case .account:
            return "Account"
        case .feedback:
            return "Feedback"
        case .help:
            return "Help Center"
        case .logout:
            return "Log out"
        case .log:
            return "Log export"
        }
    }
    
    var icon: String {
        switch self {
        case .account:
            return "person"
        case .feedback:
            return "paperplane"
        case .help:
            return "questionmark.circle"
        case .logout:
            return "rectangle.portrait.and.arrow.right"
        case .log:
            return "filemenu.and.selection"
        }
    }
    
    var detail: String {
        switch self {
        case .account:
            return UserManager.shared.user?.login ?? ""
        default:
            return ""
        }
    }
}

struct Setting: Hashable {
    let title: String
    let color: Color
    let imageName: String
}

let settings: Array<SettingType> = [
    .account,
    .feedback,
    .help,
    .log,
    .logout
]

struct SettingImage: View {
    let color: Color
    let imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .foregroundStyle(color)
            .frame(width: 16, height: 16)
    }
}

struct RootSettingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let viewToDisplay: SettingType
    var body: some View {
        VStack {
            Text(viewToDisplay.title)
        }
        .background(Color.green)
        .navigationBarBackButtonHidden()
    }
}

struct SettingsView: View {
    
    @Binding var isLogined: Bool
    
    @State var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Settings")
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                VStack {
                    Section(content: {
                        ForEach(settings, id: \.self) { setting in
                            Button(action: {
                                "#Setting# tap \(setting.title)".logI()
                                if setting == .logout {
                                    #if !MOBILE
                                    NSApplication.shared.keyWindow?.close()
                                    #endif
                                    NotificationCenter.default.post(name: NSNotification.Name.logoutNotification, object: nil)
                                }
                                if setting == .feedback {
                                    if let url = URL(string: "https://github.com/xs0521/GithubNote-MacOS/issues") {
#if !MOBILE
                                        NSWorkspace.shared.open(url)
#endif
                                    }
                                }
                                if setting == .help {
                                    if let url = URL(string: "https://github.com/xs0521/GithubNote-MacOS") {
#if !MOBILE
                                        NSWorkspace.shared.open(url)
#endif
                                    }
                                }
                                if setting == .log {
#if !MOBILE
                                    LogManager.exportLogs { success in
                                        toastMessage = "success"
                                        showToast = true
                                    }
#endif
                                }
                            }, label: {
                                ZStack {
                                    HStack {
                                        SettingImage(color: Color.init(hex: "#1A1A1A"), imageName: setting.icon)
                                            .frame(width: 16, height: 16)
                                        Text(setting.title)
                                        Spacer()
                                        if !setting.detail.isEmpty {
                                            Text(setting.detail)
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    VStack {
                                        Spacer()
                                        CustomDivider()
                                    }
                                }
                            })
                            .frame(height: 44)
                            .background(Color.init(hex: "EBEBEA"))
                            .buttonStyle(.plain)
                            .disabled(setting == .logout ? (isLogined ? false : true) : false)
                        }
                        
                    })
                    .padding(.horizontal, 20)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.init(hex: "DADADA"), lineWidth: 0.8)
                )
                .background(Color.init(hex: "EBEBEA"))
                .padding(.bottom, 30)
                .padding(.horizontal, 20)
            }
            .background(Color.init(hex: "#EFEFEE"))
        }
        .frame(width: 500)
        .toast(isPresenting: $showToast, duration: 2.0, tapToDismiss: true){
            AlertToast(displayMode: .hud, type: .systemImage("party.popper", .primary), title: toastMessage)
        }
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}

