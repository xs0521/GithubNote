//
//  CustomHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/13.
//

import SwiftUI

struct CustomHeaderView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var alertStore: AlertModelStore
    
    var title: String
    
    @Binding var isNewSending: Bool
    @Binding var isRefreshing: Bool
    
    var refreshCallBack: CommonCallBack
    var newCallBack: CommonCallBack
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? Color.init(hex: "#E0E0E0") : Color.init(hex: "#393835"))
            Spacer()
            HStack {
                if isRefreshing {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 30)
                } else {
                    Button {
                        refreshCallBack()
                    } label: {
                        CustomImage(systemName: AppConst.downloadIcon)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 5)
                }
                if isNewSending {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 20, height: 30)
                } else {
                    Button {
                        newCallBack()
                    } label: {
                        CustomImage(systemName: AppConst.plusIcon)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 20, height: 30)
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    
}
