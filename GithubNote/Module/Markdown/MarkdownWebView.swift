//
//  MarkdownWebView.swift
//  Markdown
//
//  Created by xs0521 on 2024/9/20.
//

import SwiftUI
import WebKit
import AppKit

// WKWebView Wrapper for SwiftUI

struct MarkdownWebView: NSViewRepresentable {
    
    @Binding var markdownText: String
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        var isLoaded = false
        var isDidFinish = false
        
        var parent: MarkdownWebView
        
        init(_ parent: MarkdownWebView) {
            self.parent = parent
        }
        
        // Called when the WKWebView finishes loading content
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            // Inject the Markdown content into the HTML using the `renderMarkdown` function
//            let jsCode = "renderMarkdown(`\(parent.markdownText.replacingOccurrences(of: "`", with: "\\`"))`)"
//            webView.evaluateJavaScript(jsCode) { (result, error) in
//                if let error = error {
//                    "JavaScript injection error: \(error)".p()
//                }
//            }
            isDidFinish = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        
        "#MD# isLoaded \(context.coordinator.isLoaded)".p()
        
        if !context.coordinator.isLoaded {
            // Load local HTML file from the app bundle
            if let htmlPath = Bundle.main.path(forResource: "index/index", ofType: "html") {
                let htmlUrl = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: htmlUrl)
                webView.load(request)
            }
            context.coordinator.isLoaded = true
            return
        }
        
        "#MD# isDidFinish \(context.coordinator.isDidFinish)".p()
        if !context.coordinator.isDidFinish {
            return
        }
        "#MD# title \(markdownText.prefix(20))".p()
        // Inject the Markdown content into the HTML using the `renderMarkdown` function
        let jsCode = "renderMarkdown(`\(markdownText.replacingOccurrences(of: "`", with: "\\`"))`)"
        webView.evaluateJavaScript(jsCode) { (result, error) in
            if let error = error {
                "JavaScript injection error: \(error)".p()
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
