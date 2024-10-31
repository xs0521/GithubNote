//
//  MarkdownWebView.swift
//  Markdown
//
//  Created by xs0521 on 2024/9/20.
//

import SwiftUI
import WebKit
#if MOBILE
import UIKit
#else
import AppKit
#endif

#if MOBILE
typealias AppViewRepresentable = UIViewRepresentable
#else
typealias AppViewRepresentable = NSViewRepresentable
#endif

// WKWebView Wrapper for SwiftUI

struct MarkdownWebView: AppViewRepresentable {
#if MOBILE
    typealias UIViewType = WKWebView
#endif
    @Binding var markdownText: String
#if MOBILE
    func makeUIView(context: Context) -> WKWebView {
        return makeView(context: context)
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        updateView(webView, context: context)
    }
#else
    func makeNSView(context: Context) -> WKWebView {
        return makeView(context: context)
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        updateView(webView, context: context)
    }
#endif
    
    private func makeView(context: Context) -> WKWebView {
        
        let schemeHandler = CustomURLSchemeHandler()
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: AppConst.scheme)
        let webView = WKWebView(frame: .zero, configuration: configuration)
#if DEBUG
        webView.isInspectable = true
#endif
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    private func updateView(_ webView: WKWebView, context: Context) {
        
        if !context.coordinator.isLoaded {
            "#MD# isLoaded \(context.coordinator.isLoaded)".logI()
            context.coordinator.isLoaded = true
            // Load local HTML file from the app bundle
            if let htmlPath = Bundle.main.path(forResource: "index/index", ofType: "html") {
                let htmlUrl = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: htmlUrl)
                webView.load(request)
            }
            return
        }
        
        if !context.coordinator.isDidFinish {
            "#MD# did not Finished".logW()
            return
        }
        
        if !context.coordinator.isLaunched {
#if DEBUG
            let jsCode = "debugExecute()"
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if let error = error {
                    "JavaScript injection error: \(error)".logE()
                }
            }
#endif
            "#MD# isLaunched".logI()
            context.coordinator.isLaunched = true
        }
        
        DispatchQueue.global().async {
            if context.coordinator.currentText == markdownText {
                "#MD# content no change".logI()
                return
            }
            context.coordinator.currentText = markdownText
            "#MD# title \(markdownText.prefix(20))".logI()
            
            let handleImageMarkdownText = CustomURLSchemeHandler.handleImageText(markdownText)
    
            let dictionary: [String: Any] = ["content": handleImageMarkdownText]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return }
            guard let sendContent = String(data: jsonData, encoding: .utf8) else { return }
            
            let jsCode = "renderMarkdown(\(sendContent))"
            DispatchQueue.main.async {
                webView.evaluateJavaScript(jsCode) { (result, error) in
                    if let error = error {
                        "JavaScript injection error: \(error)".logE()
                    }
                }
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        var isLoaded = false
        var isDidFinish = false
        var isLaunched = false
        
        var currentText = ""
        
        var parent: MarkdownWebView
        
        init(_ parent: MarkdownWebView) {
            self.parent = parent
        }
        
        // Called when the WKWebView finishes loading content
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            "#MD# didFinish".logI()
            isDidFinish = true
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            "#MD# error \(error.localizedDescription)".logE()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

//struct MarkdownWebViewContentView: View {
//    let markdownText = """
//    # SwiftUI with Marked.js
//    This is an example of rendering **Markdown** using Marked.js.
//    - You can use bullet points
//    - Add [links](https://www.apple.com)
//    """
//    
//    var body: some View {
//        MarkdownWebView(markdownText: markdownText)
//            .frame(width: 800, height: 400)
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MarkdownWebViewContentView()
//    }
//}