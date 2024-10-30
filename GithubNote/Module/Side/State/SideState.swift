//
//  SideState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/25.
//

import Foundation
import SwiftUIFlux

struct SideState: FluxState, Codable {
    
    var isReposVisible: Bool = false
    var selectionRepo: RepoModel? = AppUserDefaults.repo
}
