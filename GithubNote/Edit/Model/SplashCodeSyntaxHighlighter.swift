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


struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
  private let syntaxHighlighter: SyntaxHighlighter<AttributedStringOutputFormat>

  init(theme: Splash.Theme) {
    self.syntaxHighlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
  }

  func highlightCode(_ content: String, language: String?) -> Text {
//    guard language?.lowercased() == "swift" else {
//      return Text(content)
//    }
    let value = self.syntaxHighlighter.highlight(content)
    return Text(AttributedString(value))
  }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
  static func splash(theme: Splash.Theme) -> Self {
    SplashCodeSyntaxHighlighter(theme: theme)
  }
}

