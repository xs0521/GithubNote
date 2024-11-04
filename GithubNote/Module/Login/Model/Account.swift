//
//  User.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import Foundation

class UserManager {
    
    static let shared = UserManager()
    private let loginFileName = "login.json"
    
    var user: UserModel?
    
    init() {
        let fileURL = path().appendingPathComponent(loginFileName)
        do {
            let data = try Data.init(contentsOf: fileURL)
            save(data)
        } catch {
            "save: \(error)".logE()
        }
    }
    
    func save(_ data: Data?) -> Void {
        let fileURL = path().appendingPathComponent(loginFileName)
        if data == nil {
            do {
                self.user = nil
                try FileManager.default.removeItem(at: fileURL)
            } catch {
            }
            return
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            self.user = try? decoder.decode(UserModel.self, from: data!)
            try data?.write(to: fileURL)
            "save: \(fileURL)".logI()
        } catch {
            "save: \(error)".logE()
        }
    }
    
    func isLogin() -> Bool {
        return user == nil ? false : true
    }
    
    // 确定要保存文件的位置，通常在用户的文档目录下
    func path() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct UserModel: APIModelable, Identifiable, Hashable, Equatable, Codable {
    
    var uuid: String?
    
    var identifier: String {
        return "\(id ?? 0)-\(uuid ?? "")"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int?
    let login, nodeId, avatarUrl, gravatarId: String?
    let url, htmlUrl, followersUrl, followingUrl: String?
    let gistsUrl, starredUrl, subscriptionsUrl, organizationsUrl: String?
    let reposUrl, eventsUrl, receivedEventsUrl: String?
    let type, userViewType: String?
    let siteAdmin: Bool?
    let name, company, blog, location, email, hireable, bio, twitterUsername: String?
    let publicRepos, publicGists, followers, following: Int?
    let createdAt, updatedAt: String?
    let privateGists, totalPrivateRepos, ownedPrivateRepos, diskUsage, collaborators: Int?
    let twoFactorAuthentication: Bool?
    let notificationEmail: String?
    
    struct Plan: Codable {
        let name: String?
        let space, collaborators, privateRepos: Int?
    }
    
    let plan: Plan?
}
