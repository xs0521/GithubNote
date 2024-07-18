//
//  Request.swift
//  GithubNote
//
//  Created by xs0521 on 2024/3/24.
//

import Foundation

typealias ReposDataCallBack = ([Repo]) -> ()
typealias IssueDataCallBack = ([Issue]) -> ()
typealias IssueCreateDataCallBack = (Issue?) -> ()
typealias IssueCommentDataCallBack = (Int, [Comment]) -> ()
typealias CommentDataCallBack = (Comment?) -> ()
typealias CommentCallBack = (Bool) -> ()
typealias ImagesDataCallBack = ([GithubImage]) -> ()

struct Request {
    
    static let host = "https://api.github.com"
    
    static func createIssue(title: String, body: String = "", completion: @escaping IssueCreateDataCallBack) {
        
        let url = URL(string: "\(host)/repos/\(Account.owner)/\(Account.repo)/issues")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let parameters = ["title": title, "body": body]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error creating issue: \(error)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201, let data = data {
                    // Comment updated successfully
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let issueJson = json as? [String: Any] {
                            let jsonData = try JSONSerialization.data(withJSONObject: issueJson, options: [])
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let issue = try decoder.decode(Issue.self, from: jsonData)
                            completion(issue)
                            "Create issue successfully.".p()
                        }
                    } catch {
                        "Error decoding JSON: \(error.localizedDescription)".p()
                    }
                } else {
                    completion(nil)
                    "Error: \(httpResponse.statusCode)".p()
                }
            }
        }
        
        task.resume()
    }
    
    static func createComment(issuesNumber: Int, content: String, completion: @escaping CommentDataCallBack) {
        
        let apiUrl = URL(string: "\(host)/repos/\(Account.owner)/\(Account.repo)/issues/\(issuesNumber)/comments")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["body": content]
        let jsonData = try! JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201, let data = data {
                    // Comment updated successfully
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let comment = json as? [String: Any] {
                            var item = Comment()
                            item.body = comment["body"] as? String ?? ""
                            item.commentid = comment["id"] as? Int ?? 0
                            completion(item)
                            "Create comment successfully.".p()
                        }
                    } catch {
                        "Error decoding JSON: \(error.localizedDescription)".p()
                    }
                } else {
                    completion(nil)
                    "Error: \(httpResponse.statusCode)".p()
                }
            }
        }
        
        task.resume()
    }
        
    static func updateComment(content: String, commentId: String, completion: @escaping CommentCallBack) {
        
        let apiUrl = URL(string: "\(host)/repos/\(Account.owner)/\(Account.repo)/issues/comments/\(commentId)")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["body": content]
        let jsonData = try! JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Comment updated successfully
                    "Comment updated successfully.".p()
                    completion(true)
                } else {
                    "Error: \(httpResponse.statusCode)".p()
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    static func getReposData(completion: @escaping ReposDataCallBack) {
        
        let apiUrl = URL(string: "\(host)/user/repos")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion([])
                return
            }
            
            var list = [Repo]()
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let repos = json as? [[String: Any]] {
                        for repo in repos {
                            let jsonData = try JSONSerialization.data(withJSONObject: repo, options: .prettyPrinted)
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                let issue = try decoder.decode(Repo.self, from: jsonData)
                                list.append(issue)
                            } catch {
                                print(String(describing: error)) // <- ✅ Use this for debuging!
                            }    
                        }
                    }
                } catch {
                    "Error decoding JSON: \(error.localizedDescription)".p()
                }
            }
            completion(list)
        }
        
        task.resume()
    }
    
    static func getRepoIssueData(_ repo: String, completion: @escaping IssueDataCallBack) {
        
        let apiUrl = URL(string: "\(host)/repos/\(Account.owner)/\(repo)/issues")!
        
        var request = URLRequest(url: apiUrl)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion([])
                return
            }
            
            var list = [Issue]()
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let issues = json as? [[String: Any]] {
                        for issue in issues {
                            let jsonData = try JSONSerialization.data(withJSONObject: issue, options: [])
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let issue = try decoder.decode(Issue.self, from: jsonData)
                            list.append(issue)
                        }
                    }
                } catch {
                    "Error decoding JSON: \(error.localizedDescription)".p()
                }
            }
            completion(list)
        }
        
        task.resume()
    }
    
    static func getIssueCommentsDataV2(issuesNumber: Int, completion: @escaping IssueCommentDataCallBack) {
        
        let apiUrl = URL(string: "\(host)/repos/\(Account.owner)/\(Account.repo)/issues/\(issuesNumber)/comments")!
        var request = URLRequest(url: apiUrl)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion(issuesNumber, [])
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let commentsData = json as? [[String: Any]] {
                        var list = [Comment]()
                        commentsData.forEach { data in
                            var item = Comment()
                            item.body = data["body"] as? String ?? ""
                            item.commentid = data["id"] as? Int ?? 0
                            list.append(item)
                        }
                        completion(issuesNumber, list)
                    }
                } catch {
                    "Error decoding JSON: \(error.localizedDescription)".p()
                }
            }
        }
        
        task.resume()
    }
    
    static func getIssueCommentsData(issuesNumber: Int, completion: @escaping IssueCommentDataCallBack) {
        
        let apiUrl = URL(string: "\(host)/repos/\(Account.owner)/\(Account.repo)/issues/\(issuesNumber)")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion(issuesNumber, [])
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let issueData = json as? [String: Any] {
                        let title = issueData["title"] as? String ?? ""
                        let comments = issueData["comments"] as? Int ?? 0
                        
                        "Title: \(title)".p()
                        "Number of Comments: \(comments)".p()
                        
                        // Process comments if needed
                        if let commentsUrl = issueData["comments_url"] as? String {
                            getComments(issuesNumber: issuesNumber, commentsUrl: commentsUrl) { issuesNumber, comments in
                                completion(issuesNumber, comments)
                            }
                        }
                    }
                } catch {
                    "Error decoding JSON: \(error.localizedDescription)".p()
                }
            }
        }
        
        task.resume()
    }
    
    static func getComments(issuesNumber: Int, commentsUrl: String, completion: @escaping IssueCommentDataCallBack) {
        
        let apiUrl = URL(string: commentsUrl)!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion(issuesNumber, [])
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let comments = json as? [[String: Any]] {
                        var list = [Comment]()
                        for comment in comments {
                            var item = Comment()
                            item.body = comment["body"] as? String ?? ""
                            item.commentid = comment["id"] as? Int ?? 0
                            list.append(item)
                        }
                        completion(issuesNumber, list)
                    }
                } catch {
                    "Error decoding JSON: \(error.localizedDescription)".p()
                }
            }
        }
        
        task.resume()
    }
    
    static func getRepoFiles(completion: @escaping ImagesDataCallBack) {
        
        let apiUrl = URL(string: "\(host)/repos/\(Account.owner)/\(Account.repo)/contents/images")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.addValue("token \(Account.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                "Error: \(error.localizedDescription)".p()
                completion([])
                return
            }
            
            var list = [GithubImage]()
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let images = json as? [[String: Any]] {
                        for imageData in images {
                            let jsonData = try JSONSerialization.data(withJSONObject: imageData, options: [])
                            let decoder = JSONDecoder()
                            let imageModel = try decoder.decode(GithubImage.self, from: jsonData)
                            list.append(imageModel)
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            }
            completion(list)
        }
        
        task.resume()
    }
    
    static func getRepoCreateImagesFold(completion: @escaping CommentCallBack) {
        
        
    }
}
