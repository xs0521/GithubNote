//
//  NoteContentHeaderView.swift
//  GithubNoteMobile
//
//  Created by xs0521 on 2024/10/23.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUIFlux

struct NoteContentHeaderView: View {
    
    @State var url = UserManager.shared.user?.avatarUrl ?? ""
    @State var nick = UserManager.shared.user?.name ?? ""
    
    var body: some View {
        VStack {
            HStack {
                WebImage(url: URL(string: url)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 30))
                    }
                    .indicator(.activity) // Activity Indicator
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                Text(nick)
                Spacer()
                Button(action: {
                    
                }, label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })
                .padding(.trailing, 16)
            }
            .frame(height: 40)
        }
    }
}

#Preview {
    NoteContentHeaderView()
}
