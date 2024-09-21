//
//  SettingsView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/9/21.
//

import SwiftUI
import AppKit

enum SettingType {
    case account
    case feedback
    case help
    case logout
    
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
        }
    }
    
    var detail: String {
        switch self {
        case .account:
            return Account.owner
        default:
            return ""
        }
    }
    
    var disabledNavigation: Bool {
        return true
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
                                    NSApplication.shared.keyWindow?.close()
                                    NotificationCenter.default.post(name: NSNotification.Name.logoutNotification, object: nil)
                                }
                                if setting == .feedback {
                                    if let url = URL(string: "https://github.com/xs0521/GithubNote-MacOS/issues") {
                                        NSWorkspace.shared.open(url)
                                    }
                                }
                                if setting == .help {
                                    if let url = URL(string: "https://github.com/xs0521/GithubNote-MacOS") {
                                        NSWorkspace.shared.open(url)
                                    }
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
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

