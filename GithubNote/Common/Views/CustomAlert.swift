//
//  CustomAlert.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/15.
//

import SwiftUI

struct CustomAlert: View {
    
    @Binding var isVisible: Bool
    let title: String
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack {
                        Text(title)
                            .lineLimit(1)
                            .font(.headline)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .padding(.horizontal, 16)
                        Text(message)
                            .font(.body)
                            .lineSpacing(3.0)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                    }
                    Divider()
                    HStack {
                        Button("Cancel") {
                            onCancel()
                            isVisible = false
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Divider()
                        Button("Confirm") {
                            onConfirm()
                            isVisible = false
                        }
                        .fontWeight(.bold)
                        .buttonStyle(.plain)
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 44)
                }
                .frame(width: 270)
                .frame(minHeight: 136)
                .background(Color.init(hex: "#F2F2F2"))
                .cornerRadius(14)
            }
            .transition(.opacity)
            .animation(.easeInOut, value: isVisible)
        }
    }
}

//#Preview {
//    CustomAlert(isVisible: .constant(true), title: "通知", message: "通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容通知内容") {
//        
//    } onCancel: {
//        
//    }
//
//}

struct CustomAlertModifier: ViewModifier {
    @Binding var isVisible: Bool
    let title: String
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content // 原始视图
            if isVisible {
                CustomAlert(
                    isVisible: $isVisible,
                    title: title,
                    message: message,
                    onConfirm: onConfirm,
                    onCancel: onCancel
                )
            }
        }
    }
}

extension View {
    func customAlert<Content: View>(
        isVisible: Binding<Bool>,
        title: String,
        message: String,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) -> some View {
        modifier(CustomAlertModifier(
            isVisible: isVisible,
            title: title,
            message: message,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
}
