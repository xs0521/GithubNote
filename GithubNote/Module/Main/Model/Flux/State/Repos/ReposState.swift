//
//  ReposState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation
import SwiftUIFlux

struct ReposState: FluxState, Codable {
    
    var items: [RepoModel] = []
}
