//
//  CommentState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/29.
//

import Foundation
import SwiftUIFlux

struct CommentState: FluxState, Codable {
    var items: [Comment] = []
    var editItem: Comment?
    var deleteItem: Comment?
}

