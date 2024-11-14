//
//  NoteWriteModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/24.
//

import Foundation

enum UploadType: Codable {
    
    case no
    case normal
    case sending
    case fail
    
    var imageName: String {
        switch self {
        case .no, .sending:
            return ""
        case .normal:
            return "arrow.up"
        case .fail:
            return "xmark"
        }
    }
    
}
