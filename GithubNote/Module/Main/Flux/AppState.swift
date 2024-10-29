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
    var issuesStates: IssuesState
    
    init() {
        self.reposStates = ReposState(items: [])
        self.sideStates = SideState()
        self.issuesStates = IssuesState()
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
        state.isReposVisible = action.visible
        state.selectionRepo = AppUserDefaults.repo
    default:
        break
    }
    return state
}

func IssuesStateReducer(state: IssuesState, action: Action) -> IssuesState {
    var state = state
    switch action {
    case let action as IssuesActions.SetList:
        state.items = action.list
    case let action as IssuesActions.WillEditAction:
        state.editItem = action.issue
    case let action as IssuesActions.WillDeleteAction:
        state.deleteItem = action.issue
    default:
        break
    }
    return state
}
