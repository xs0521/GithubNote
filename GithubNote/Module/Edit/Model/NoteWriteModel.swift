//
//  NoteWriteModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/24.
//

import Foundation

enum UploadType {
    
    case normal
    case sending
    case success
    case fail
    
    var imageName: String {
        switch self {
        case .normal:
            return "arrow.up.square.fill"
        case .sending:
            return "arrow.up.square.fill"
        case .success:
            return "checkmark.square.fill"
        case .fail:
            return "xmark.square.fill"
        }
    }
    
}
