//
//  ImagesState.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import SwiftUIFlux

struct ImagesState: FluxState, Codable {
    var isPreview = false
    var isImageBrowserVisible: Bool = false {
        didSet {
            list.removeAll()
        }
    }
    var list: [GithubImage] = []
}
