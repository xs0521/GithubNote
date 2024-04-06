//
//  IssuesCreateView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation
import SwiftUI

struct IssuesCreateView: View {
    
    @Binding var content: String
    @State private var isIssuesloading: Bool = true
    
    var body: some View {
        VStack {
            TextField("Input title", text: $content)
                .frame(height: 44)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .textFieldStyle(.plain)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
