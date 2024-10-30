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
    var commentStates: CommentState
    var writeStates: WriteState
    var imagesState: ImagesState
    
    init() {
        self.reposStates = ReposState(items: [])
        self.sideStates = SideState()
        self.issuesStates = IssuesState()
        self.commentStates = CommentState()
        self.writeStates = WriteState()
        self.imagesState = ImagesState()
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
        state.editItem = action.item
    case let action as IssuesActions.WillDeleteAction:
        state.deleteItem = action.item
    default:
        break
    }
    return state
}

func CommentStateReducer(state: CommentState, action: Action) -> CommentState {
    var state = state
    switch action {
    case let action as CommentActions.SetList:
        state.items = action.list
    case let action as CommentActions.WillDeleteAction:
        state.deleteItem = action.item
    default:
        break
    }
    return state
}

func WriteStateReducer(state: WriteState, action: Action) -> WriteState {
    var state = state
    switch action {
    case let action as WriteActions.edit:
        state.editIsShown = action.editIsShown
    case let action as WriteActions.upload:
        state.uploadState = action.state
    default:
        break
    }
    return state
}

func ImagesStateReducer(state: ImagesState, action: Action) -> ImagesState {
    var state = state
    switch action {
    case let action as ImagesActions.Preview:
        state.isPreview = action.on
    case let action as ImagesActions.SetList:
        state.list = action.list
    case let action as ImagesActions.isImageBrowserVisible:
        state.isImageBrowserVisible = action.on
    default:
        break
    }
    return state
}
