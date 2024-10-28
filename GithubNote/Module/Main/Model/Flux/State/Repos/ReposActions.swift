//
//  ReposActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/24.
//

import Foundation
import SwiftUIFlux

struct ReposActions {
    
    class Config {
        var page = 1
        var list = [RepoModel]()
    }
    
    struct FetchList: AsyncAction {
        
        let readCache: Bool
        let config = Config()
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            requestAllRepo(readCache) {
                dispatch(SetList(list: config.list))
            }
        }
        
        private func requestAllRepo(_ readCache: Bool = true, _ completion: @escaping CommonCallBack) -> Void {
            
            if readCache {
                CacheManager.fetchRepos { list in
                    "#request# Repo all cache \(list.count)".logI()
                    config.list = list
//                    if let repo = list.first(where: {$0.name == AppUserDefaults.repo?.name}) {
//                        config.select = repo
//                    }
                    completion()
                }
                return
            }
            
            config.page = 1
            let allRepos: [RepoModel] = []
            requestRepo(config.page, allRepos, readCache, true) { netList, success, more in
                "#request# Repo all \(netList.count)".logI()
                CacheManager.insertRepos(repos: netList, deleteNoFound: true) {
                    CacheManager.fetchRepos { list in
                        config.list = list
                        let container = config.list.contains { item in
                            item.name == AppUserDefaults.repo?.name
                        }
//                        if !container {
//                            config.select = list.first
//                        }
                        completion()
                    }
                }
            }
        }
        
        private func requestRepo(_ page: Int, _ repos: [RepoModel], _ readCache: Bool = true, _ next: Bool = false, _ completion: @escaping RequestCallBack<[RepoModel]>) -> Void {
            
            var repos = repos
            
            "#request# Repo start page \(page) readCache \(readCache) next \(next)".logI()
            
            Networking<RepoModel>().request(API.repos(page: page), parseHandler: ModelGenerator(snakeCase: true)) { (data, _, _) in
                
                guard let list = data else {
                    "#request# Repo page \(page) error".logE()
                    completion(repos, false, false)
                    return
                }
                
                "#request# Repo page \(page) \(list.count)".logI()
                
//                if let repo = list.first(where: {$0.name == AppUserDefaults.repo?.name}) {
//                    config.select = repo
//                }
                
                repos.append(contentsOf: list)
                
                if next {
                    if list.isEmpty {
                        completion(repos, true, false)
                    } else {
                        config.page += 1
                        requestRepo(config.page, repos, false, next, completion)
                    }
                } else {
                    completion(repos, true, !list.isEmpty)
                }
            }
        }
    }
    
    struct SetList: Action {
        let list: [RepoModel]
    }
}
