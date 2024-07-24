//
//  SplashCodeSyntaxHighlighter.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import SwiftUI
import Foundation
import MarkdownUI
import Splash
import Highlightr


struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
  private let syntaxHighlighter: SyntaxHighlighter<AttributedStringOutputFormat>

  init(theme: Splash.Theme) {
    self.syntaxHighlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
  }

  func highlightCode(_ content: String, language: String?) -> Text {
//    guard language?.lowercased() == "swift" else {
//      return Text(content)
//    }
      
    let highlightr = Highlightr()
      highlightr?.setTheme(to: "paraiso-dark")
      guard let value = highlightr?.highlight(content, as: "swift") else {
        let value = self.syntaxHighlighter.highlight(content)
        return Text(AttributedString(value))
      }
    return Text(AttributedString(value))
  }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
  static func splash(theme: Splash.Theme) -> Self {
    SplashCodeSyntaxHighlighter(theme: theme)
  }
}

