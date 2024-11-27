//
//  VersionUpdateManager.swift
//  GithubNote
//
//  Created by xs0521 on 2024/11/27.
//

import Foundation
import AppKit

struct GitHubRelease: Codable {
    let tag_name: String
    let body: String?
}

struct VersionUpdateManagerSetup: Setupable {
    static func setup() {
        VersionUpdateManager.promptForUpdate()
    }
}

class VersionUpdateManager {
    
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    let githubRepo = "xs0521/GithubNote"
    
    func checkForUpdate(completion: @escaping (Bool, GitHubRelease?) -> Void) {
        let urlString = "https://api.github.com/repos/\(githubRepo)/releases/latest"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                "Error fetching release data: \(error?.localizedDescription ?? "Unknown error")".logE()
                completion(false, nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let release = try decoder.decode(GitHubRelease.self, from: data)
                let latestVersion = release.tag_name.trimmingCharacters(in: .whitespacesAndNewlines)
                if self.isNewVersion(current: self.currentVersion, latest: latestVersion) {
                    completion(true, release)
                } else {
                    completion(false, nil)
                }
            } catch {
                "Error decoding release data: \(error.localizedDescription)".logE()
                completion(false, nil)
            }
        }.resume()
    }
    
    private func isNewVersion(current: String, latest: String) -> Bool {
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        let latestParts = latest.split(separator: ".").compactMap { Int($0) }
        
        for (current, latest) in zip(currentParts, latestParts) {
            if current < latest {
                return true
            } else if current > latest {
                return false
            }
        }
        
        return latestParts.count > currentParts.count
    }
    
    static func promptForUpdate() {
        
        let currentTime = Int(Date().timeIntervalSince1970)
        if AppUserDefaults.lastCheckVersionTime > 0 {
            if currentTime - AppUserDefaults.lastCheckVersionTime < 259200 {
                "#VU# do not check version".logI()
                return
            }
        }
        AppUserDefaults.lastCheckVersionTime = currentTime
        
        let updateManager = VersionUpdateManager()
        updateManager.checkForUpdate { isNewVersionAvailable, release in
            DispatchQueue.main.async {
                if isNewVersionAvailable, let release = release {
                    
                    "#VU# new version \(release.tag_name)".logI()
                    
                    let alert = NSAlert()
                    alert.messageText = "V\(release.tag_name)"
                    let textField = NSTextField(labelWithString: release.body ?? "")
                    textField.isEditable = false
                    textField.isBordered = false
                    textField.drawsBackground = false
                    textField.alignment = .left
                    textField.lineBreakMode = .byWordWrapping
                    textField.translatesAutoresizingMaskIntoConstraints = false
                    textField.preferredMaxLayoutWidth = 400
                    alert.accessoryView = textField
                    
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "update_now".language())
                    alert.addButton(withTitle: "remind_me".language())
                    
                    if alert.runModal() == .alertFirstButtonReturn {
                        if let url = URL(string: "https://github.com/\(updateManager.githubRepo)/releases/latest") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                } else {
                    "#VU# is latest version".logI()
                }
            }
        }
    }
}



