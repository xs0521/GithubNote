//
//  IssuesActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/29.
//

import Foundation
import SwiftUIFlux

struct IssuesActions {
    
    class Config {
        var page = 1
        var list = [Issue]()
    }
    
    struct FetchList: AsyncAction {
        
        let readCache: Bool
        let config = Config()
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            requestAllIssue(readCache) { value in
                dispatch(SetList(list: config.list))
                completion?(value)
            }
        }
        
        private func requestAllIssue(_ readCache: Bool = true, _ completion: @escaping CommonTCallBack<Bool>) -> Void {
            
            if AppUserDefaults.repo == nil {
                ToastManager.shared.show("Please select a code repository")
                completion(false)
                return
            }
            
            if readCache {
                CacheManager.fetchIssues { list in
                    "#request# issue all cache \(list.count)".logI()
                    config.list = list
                    completion(true)
                }
                return
            }
            
            config.page = 1
            let allIssue: [Issue] = []
            requestIssue(config.page, allIssue, false, true) { loadList, success, more in
                "#request# issue all \(loadList.count)".logI()
                CacheManager.insertIssues(issues: loadList, deleteNoFound: true) {
                    CacheManager.fetchIssues { list in
                        config.list = list
                        completion(true)
                    }
                }
            }
        }
        
        private func requestIssue(_ page: Int, _ issues: [Issue], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[Issue]>) -> Void {
            guard let repoName = CacheManager.shared.currentRepo?.name else { return }
            
            var issues = issues
            
            "#request# Issue start page \(page) readCache \(readCache) next \(next) repoName \(repoName)".logI()
            
            Networking<Issue>().request(API.repoIssues(repoName: repoName, page: page),
                                        parseHandler: ModelGenerator(snakeCase: true, filter: true)) { (data, _, _) in
                guard let list = data else {
                    "#request# Issue page \(page) error".logE()
                    completion(issues, false, false)
                    return
                }
                
                "#request# Issue page \(page) \(list.count)".logI()
                
                issues.append(contentsOf: list)
                
                if next {
                    if list.isEmpty {
                        completion(issues, true, false)
                    } else {
                        config.page += 1
                        requestIssue(config.page, issues, false, next, completion)
                    }
                } else {
                    completion(issues, true, !list.isEmpty)
                }
            }
        }
    }
    
    struct Create: AsyncAction {
        
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            createIssue { issue in
                guard let issue = issue else {
                    completion?(false)
                    return
                }
                CacheManager.insertIssues(issues: [issue]) {
                    issueStore.select = issue
                    completion?(true)
                }
            }
        }
        
        private func createIssue(_ completion: @escaping CommonTCallBack<Issue?>) -> Void {
            
            let title = AppConst.issueMarkdown
            let body = AppConst.issueBodyMarkdown
            Networking<Issue>().request(API.newIssue(title: title, body: body), parseHandler: ModelGenerator(snakeCase: true)) { data, cache, _ in
                guard let issue = data?.first else {
                    completion(nil)
                    return
                }
                completion(issue)
            }
        }
    }
    
    struct Edit: AsyncAction {
        
        let item: Issue
        let title: String
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            updateIssueTitle(item, title) { finish in
                completion?(finish)
            }
        }
        
        func updateIssueTitle(_ issue: Issue?, _ title: String, completion: @escaping CommonTCallBack<Bool>) -> Void {
    
            guard let issue = issue else { return }
    
            "#issue# update title \(title)".logI()
    
            let body = issue.body ?? ""
            guard let issueId = issue.number else { return }
            Networking<Issue>().request(API.updateIssue(issueId: issueId, state: .open, title: title, body: body)) { data, cache, _ in
                if data != nil {
                    "#issue# update success".logI()
                    var issue = issue
                    issue.title = title
                    CacheManager.updateIssues([issue]) {
                        completion(true)
                    }
                } else {
                    "#issue# update fail".logI()
                    ToastManager.shared.showFail("fail")
                    completion(false)
                }
            }
        }
    }
    
    struct Delete: AsyncAction {
        
        let item: Issue
        let completion: CommonTCallBack<Bool>?
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            deleteIssue(item) { finish in
                completion?(finish)
            }
        }
        
        private func deleteIssue(_ issue: Issue, completion: @escaping CommonTCallBack<Bool>) -> Void {
            guard let number = issue.number, let title = issue.title, let body = issue.body else { return }
            Networking<Issue>().request(API.updateIssue(issueId: number, state: .closed, title: title, body: body)) { data, cache, _ in
                if data != nil {
                    guard let issueId = issue.id else { return }
                    CacheManager.deleteIssue([issueId]) {
                        guard let tableName = CacheManager.shared.manager?.commentTableName(issueId), let url = issue.url else {
                            completion(true)
                            return
                        }
                        CacheManager.deleteComment(url, tableName) {
                            completion(true)
                        }
                    }
                } else {
                    ToastManager.shared.showFail("fail")
                    completion(false)
                }
            }
        }
    }
    
    struct SetList: Action {
        let list: [Issue]
    }
    
    struct WillEditAction: Action {
        let item: Issue?
    }
    
    struct WillDeleteAction: Action {
        let item: Issue?
    }
}
