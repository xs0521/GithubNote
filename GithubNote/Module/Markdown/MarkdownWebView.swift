//
//  MarkdownWebView.swift
//  Markdown
//
//  Created by xs0521 on 2024/9/20.
//

import SwiftUI
import WebKit
import AppKit
import ObjectiveC.runtime

// WKWebView Wrapper for SwiftUI

struct MarkdownWebView: NSViewRepresentable {
    
    @Binding var markdownText: String
    
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
            isDidFinish = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        
        let schemeHandler = CustomURLSchemeHandler()
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "http")
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "https")
        let webView = WKWebView(frame: .zero, configuration: configuration)
#if DEBUG
        webView.isInspectable = true
#endif
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        
        if !context.coordinator.isLoaded {
            "#MD# isLoaded \(context.coordinator.isLoaded)".logI()
            // Load local HTML file from the app bundle
            if let htmlPath = Bundle.main.path(forResource: "index/index", ofType: "html") {
                let htmlUrl = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: htmlUrl)
                webView.load(request)
            }
            context.coordinator.isLoaded = true
            return
        }
        
        if !context.coordinator.isDidFinish {
            "#MD# no isDidFinished".logW()
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
            // Inject the Markdown content into the HTML using the `renderMarkdown` function
            let escapedMarkdownText = markdownText.replacingOccurrences(of: "`", with: "\\`")
            
            let jsCode = "renderMarkdown(`\(escapedMarkdownText)`)"
            DispatchQueue.main.async {
                webView.evaluateJavaScript(jsCode) { (result, error) in
                    if let error = error {
                        "JavaScript injection error: \(error)".logE()
                    }
                }
            }
        }
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

extension WKWebView {
    static let swizzleHandlesURLScheme: Void = {
        let originalSelector = #selector(handlesURLScheme(_:))
        let swizzledSelector = #selector(swizzledHandlesURLScheme(_:))

        if let originalMethod = class_getClassMethod(WKWebView.self, originalSelector),
           let swizzledMethod = class_getClassMethod(WKWebView.self, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()

    @objc class func swizzledHandlesURLScheme(_ urlScheme: String) -> Bool {
        if urlScheme == "http" || urlScheme == "https" {
            return false  // 这里返回 NO，避免系统处理，使用自定义 handler 处理
        } else {
            return swizzledHandlesURLScheme(urlScheme)  // 调用原始实现
        }
    }
}
