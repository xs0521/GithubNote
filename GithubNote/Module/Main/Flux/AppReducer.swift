//
//  AppReducer.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation
import SwiftUIFlux

func appStateReducer(state: AppState, action: Action) -> AppState {
    var state = state
    state.reposStates = reposStateReducer(state: state.reposStates, action: action)
    state.sideStates = SideStateReducer(state: state.sideStates, action: action)
    state.issuesStates = IssuesStateReducer(state: state.issuesStates, action: action)
    state.commentStates = CommentStateReducer(state: state.commentStates, action: action)
    return state
}
