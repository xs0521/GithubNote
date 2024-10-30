//
//  WriteState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import SwiftUIFlux

struct WriteState: FluxState, Codable {
    var editIsShown: Bool = false
    var showImageBrowser: Bool = false
    var uploadState: UploadType = .normal
}
