//
//  ImagesModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/13.
//

import Foundation
import SDWebImage

class ImagesModel {
    static let shared = ImagesModel()
}

struct SDWebImageDownloaderSetup: Setupable {
    static func setup() {
        "#image# accessToken length \(Account.accessToken.count)".logI()
        SDWebImageDownloader.shared.setValue("Bearer \(Account.accessToken)", forHTTPHeaderField: "Authorization")
    }
}

struct GithubImage: APIModelable, Identifiable, Hashable, Equatable {
    
    var index: Int?
    var id: String?
    var uuid: String?
    
    let name, path, sha: String
    let size: Int
    let url, htmlURL: String
    let gitURL: String
    let downloadURL: String
    let type: String
    
    public var identifier: String {
        return "\(url)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    public static func == (lhs: GithubImage, rhs: GithubImage) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func imageUrl() -> String {
        if let url = URL(string: downloadURL) {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.query = nil
                return urlComponents.url?.absoluteString ?? ""
            }
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url
        case htmlURL = "html_url"
        case gitURL = "git_url"
        case downloadURL = "download_url"
        case type
    }

}
