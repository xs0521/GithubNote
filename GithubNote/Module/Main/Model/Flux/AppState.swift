//
//  AppState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation
import SwiftUIFlux

struct AppState: FluxState, Codable {
    var reposStates: ReposState
    var sideStates: SideState
    
    init() {
        self.reposStates = ReposState(items: [])
        self.sideStates = SideState()
    }
}

func reposStateReducer(state: ReposState, action: Action) -> ReposState {
    var state = state
    switch action {
    case let action as ReposActions.SetList:
        state.items = action.list
    default:
        break
    }
    return state
}

func SideStateReducer(state: SideState, action: Action) -> SideState {
    var state = state
    switch action {
    case let action as SideActions.ReposViewState:
        state.showReposView = action.show
    default:
        break
    }
    return state
}
