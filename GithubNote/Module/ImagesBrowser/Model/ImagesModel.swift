//
//  ImagesModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/13.
//

import Foundation

class ImagesModel {
    static let shared = ImagesModel()
}


struct GithubImage: APIModelable, Identifiable, Hashable, Equatable {
    
    var id = UUID().uuidString
    
    var uuid: String?
    
    let name, path, sha: String
    let size: Int
    let url, htmlURL: String
    let gitURL: String
    let downloadURL: String
    let type: String
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public static func == (lhs: GithubImage, rhs: GithubImage) -> Bool {
        return lhs.path == rhs.path
    }
    
    public func defultModel () -> Void {
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url
        case htmlURL = "html_url"
        case gitURL = "git_url"
        case downloadURL = "download_url"
        case type
    }

}
