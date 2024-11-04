//
//  ImagesModel.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/13.
//

import Foundation
import SDWebImage
import FMDB

class ImagesModel {
    static let shared = ImagesModel()
}

struct SDWebImageDownloaderSetup: Setupable {
    static func setup() {
        "#image# accessToken length \(AppUserDefaults.accessToken.count)".logI()
        SDWebImageDownloader.shared.setValue("Bearer \(AppUserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        SDWebImageManager.defaultImageCache = SDImageCache(namespace: "github.note.cache")
    }
}

struct GithubImage: APIModelable, Identifiable, Hashable, Equatable {
    
    var index: Int?
    var id: Int?
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
        var imageUrl = ""
        if let url = URL(string: downloadURL) {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.query = nil
                imageUrl = urlComponents.url?.absoluteString ?? ""
            }
        }
        return imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url
        case htmlURL = "html_url"
        case gitURL = "git_url"
        case downloadURL = "download_url"
        case type
    }

}

extension GithubImage: SQLModelable {
    
    static var tableName: String {
        let tableName = CacheManager.shared.manager?.imagesTableName() ?? "" 
        assert(!tableName.isEmpty)
        return tableName
    }
    
    static var fetchWhere: String? {
        nil
    }
    
    static func insertPreAction() {
        CacheManager.shared.manager?.createImagesTable()
    }
    
    var insertSql: String {
        """
        INSERT OR REPLACE INTO \(Self.tableName) (uuid, name, path, sha, size, url, htmlURL, gitURL, downloadURL, type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
    }
    
    func insertValues(_ index: Int) -> [Any] {
        [
            self.uuid ?? NSNull(),
            self.name,
            self.path,
            self.sha,
            self.size,
            self.url,
            self.htmlURL,
            self.gitURL,
            self.downloadURL,
            self.type
        ]
    }
    
    static var fetchSql: String {
        "SELECT * FROM \(tableName) ORDER BY idx DESC;"
    }
    
    static func item(_ resultSet: FMResultSet) -> GithubImage {
        GithubImage(
            index: Int(resultSet.int(forColumn: "idx")),
            id: 0,
            uuid: resultSet.string(forColumn: "uuid"),
            name: resultSet.string(forColumn: "name") ?? "",
            path: resultSet.string(forColumn: "path") ?? "",
            sha: resultSet.string(forColumn: "sha") ?? "",
            size: Int(resultSet.int(forColumn: "size")),
            url: resultSet.string(forColumn: "url") ?? "",
            htmlURL: resultSet.string(forColumn: "htmlURL") ?? "",
            gitURL: resultSet.string(forColumn: "gitURL") ?? "",
            downloadURL: resultSet.string(forColumn: "downloadURL") ?? "",
            type: resultSet.string(forColumn: "type") ?? ""
        )
    }
    
    var updateSql: String {
        let insertSQL = ""
        assert(!insertSQL.isEmpty)
        return insertSQL
    }
    
    static var oneTable: Bool {
        true
    }
    
    func updateValues() -> [Any] {
        []
    }
}
