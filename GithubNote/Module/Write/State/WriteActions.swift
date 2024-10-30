//
//  WriteActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import SwiftUIFlux

struct WriteActions {
    
    struct edit: Action {
        let editIsShown: Bool
    }
    
    struct upload: Action {
        let state: UploadType
    }
}
