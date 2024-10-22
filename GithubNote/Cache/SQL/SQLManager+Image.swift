//
//  SQLManager+Image.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/18.
//

import Foundation
import FMDB

extension SQLManager {
    
    func insertGithubImages(images: [GithubImage], into tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let insertSQL = """
        INSERT OR REPLACE INTO \(tableName) (uuid, name, path, sha, size, url, htmlURL, gitURL, downloadURL, type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        if database.open() {
            database.beginTransaction()
            images.forEach { image in
                do {
                    try database.executeUpdate(insertSQL, values: [
                        image.uuid ?? NSNull(),
                        image.name,
                        image.path,
                        image.sha,
                        image.size,
                        image.url,
                        image.htmlURL,
                        image.gitURL,
                        image.downloadURL,
                        image.type
                    ])
                } catch {
                    "Failed to insert GithubImage: \(error.localizedDescription)".logE()
                }
            }
            database.commit()
            "GithubImage inserted into \(tableName) successfully".logI()
        }
        database.close()
    }
    
    func fetchGithubImage(from tableName: String?, where url: String, database: FMDatabase) -> GithubImage? {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return nil
        }
        
        let selectSQL = "SELECT * FROM \(tableName) WHERE url = ?;"
        var githubImage: GithubImage?
        
        if database.open() {
            do {
                let resultSet = try database.executeQuery(selectSQL, values: [url])
                
                while resultSet.next() {
                    githubImage = GithubImage(
                        index: Int(resultSet.int(forColumn: "idx")),
                        id: "",
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
            } catch {
                "Failed to fetch GithubImage: \(error.localizedDescription)".logE()
            }
        }
        database.close()
        return githubImage
    }
    
    func fetchGithubImages(from tableName: String?, database: FMDatabase) -> [GithubImage] {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return []
        }
        
        var images = [GithubImage]()
        let selectSQL = "SELECT * FROM \(tableName) ORDER BY idx DESC;"
        
        if database.open() {
            do {
                let resultSet = try database.executeQuery(selectSQL, values: [])
                
                while resultSet.next() {
                    var image = GithubImage(
                        index: Int(resultSet.int(forColumn: "idx")),
                        id: "",
                        uuid: resultSet.string(forColumn: "uuid"),
                        name: resultSet.string(forColumn: "name") ?? "",
                        path: resultSet.string(forColumn: "path") ?? "",
                        sha: resultSet.string(forColumn: "sha") ?? "",
                        size: Int(resultSet.int(forColumn: "size")),
                        url: resultSet.string(forColumn: "url")!,
                        htmlURL: resultSet.string(forColumn: "htmlURL") ?? "",
                        gitURL: resultSet.string(forColumn: "gitURL") ?? "",
                        downloadURL: resultSet.string(forColumn: "downloadURL")!,
                        type: resultSet.string(forColumn: "type") ?? ""
                    )
                    image.defultModel()
                    images.append(image)
                }
            } catch {
                "Failed to fetch GithubImages: \(error.localizedDescription)".logE()
            }
        }
        database.close()
        
        return images
    }
    
    
    func deleteGithubImage(byUrls urls: [String], from tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let deleteSQL = "DELETE FROM \(tableName) WHERE url = ?;"
        
        if database.open() {
            urls.forEach { url in
                do {
                    try database.executeUpdate(deleteSQL, values: [url])
                } catch {
                    "Failed to delete GithubImage: \(error.localizedDescription)".logE()
                }
            }
            "GithubImage deleted successfully".logI()
        }
        database.close()
    }
    
    func deleteAllGithubImage(from tableName: String?, database: FMDatabase) {
        
        guard let tableName = tableName else {
            assert(false, "tableName error")
            return
        }
        
        let deleteSQL = "DELETE FROM \(tableName);"
        
        if database.open() {
            do {
                let result = try database.executeUpdate(deleteSQL, withArgumentsIn: [])
            } catch {
                "Failed to delete GithubImage: \(error.localizedDescription)".logE()
            }
            "GithubImage TRUNCATE successfully".logI()
        }
        database.close()
    }
}
