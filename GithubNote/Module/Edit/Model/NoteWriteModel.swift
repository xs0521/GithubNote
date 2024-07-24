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
            return "icloud.and.arrow.up"
        case .sending:
            return "icloud.and.arrow.up"
        case .success:
            return "checkmark.icloud"
        case .fail:
            return "xmark.icloud"
        }
    }
    
}
