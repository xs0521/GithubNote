//
//  CustomHeaderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/13.
//

import SwiftUI

struct CustomHeaderView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var title: String
    var refreshCallBack: CommonTCallBack<CommonCallBack>
    var newCallBack: CommonTCallBack<CommonCallBack>
    
    @State private var isNewSending: Bool = false
    @State private var isRefreshing: Bool = false
    
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
                        isRefreshing = true
                        refreshCallBack({
                            isRefreshing = false
                        })
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
                        isNewSending = true
                        newCallBack({
                            isNewSending = false
                        })
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
