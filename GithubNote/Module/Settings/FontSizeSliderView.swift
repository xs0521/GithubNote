//
//  FontSizeSliderView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/22.
//

import Foundation
import SwiftUI

struct FontSizeSliderView: View {
    
    @State private var fontScale: CGFloat = AppUserDefaults.fontSize // 默认字体大小

    var body: some View {
        HStack(spacing: 0) {
            Text("A")
                .font(.subheadline)
                .padding(.trailing, 8)
            // 滑块控件
            Slider(
                value: $fontScale,
                in: 0.7...1.3, // 字体大小范围
                step: 0.1, // 每次调整 1 的步长
                onEditingChanged: { finish in
                    
                }
            )
            .padding(.trailing, 10)
            .accentColor(.blue) // 自定义滑块颜色
            .animation(.easeInOut, value: fontScale) // 滑块动画
            Text("A")
                .font(.title)
                .padding(.leading, 1)
        }
        .onChange(of: fontScale) { oldValue, newValue in
            "#slider# newValue \(newValue)".logI()
            AppUserDefaults.fontSize = newValue
            NotificationCenter.default.post(name: NSNotification.Name.fontSize, object: nil)
        }
    }
}

#Preview {
    VStack {
        FontSizeSliderView()
            .frame(width: 200, height: 44)
    }
    .frame(width: 300, height: 44)
}
