//
//  LoginOutView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/6.
//

import Foundation
import SwiftUI
import AppKit

typealias CancelCallBack = () -> ()
typealias LoginOutCallBack = () -> ()

struct LoginOutView: View {
    
    var cancelCallBack: CancelCallBack
    var loginOutCallBack: LoginOutCallBack
    
    
    @State var ownerName = Account.owner
    @State var repoName = Account.repo
    @State var token = Account.accessToken
    
    var body: some View {
        VStack {
            ZStack {
                Color.black
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    cancelCallBack()
                }
                VStack {
                    Text("Logout")
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 30, trailing: 10))
                        .font(.largeTitle)
                    
                    Text(ownerName)
                        .foregroundStyle(Color(hex: "#7E7E7E"))
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        .font(.system(size: 18))
                    
                    Text(repoName)
                        .foregroundStyle(Color(hex: "#7E7E7E"))
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        .font(.system(size: 18))
                    
                    HStack (alignment: .center) {
                        Text(token.encrypt(20))
                            .foregroundStyle(Color(hex: "#7E7E7E"))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .font(.system(size: 18))
                            .textFieldStyle(.plain)
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(token, forType: .string)
                        }, label: {
                            Image(systemName: "doc.on.doc")
                        })
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        .buttonStyle(.plain)
                    }
                    
                    Button(action: {
                        loginOutCallBack()
                    }, label: {
                        Text("Confirm")
                            .foregroundStyle(Color(hex: "#222222"))
                            .frame(width: 180, height: 44)
                            .background(Color(hex: "#EDEDED"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    })
                    .buttonStyle(.plain)
                }
                .frame(width: 400, height: 300)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
    }
    
    func enbleStart() -> Bool {
        return !repoName.isEmpty && !token.isEmpty && !ownerName.isEmpty
    }
}

#Preview {
    LoginOutView(cancelCallBack: {
        
    }, loginOutCallBack: {
        
    })
}
