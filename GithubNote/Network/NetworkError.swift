//
//  NetworkError.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation

public enum NetworkError: Error  {
    case json(message: String)
    case dict(message: String)
    case exception(message: String)
}
