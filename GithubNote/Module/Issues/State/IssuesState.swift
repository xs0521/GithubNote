//
//  IssueState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/29.
//

import Foundation
import SwiftUIFlux

struct IssuesState: FluxState, Codable {
    var items: [Issue] = []
    var editItem: Issue?
    var deleteItem: Issue?
    var issuesHeight: CGFloat = AppUserDefaults.issuesHeight
}
