//
//  ImagesActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import SwiftUIFlux

struct ImagesActions {
    
    struct Preview: Action {
        let on: Bool
    }
    
    struct isImageBrowserVisible: Action {
        let on: Bool
    }
    
    struct SetList: Action {
        let list: [GithubImage]
    }
    
    struct FetchList: AsyncAction {
        
        let readCache: Bool
        let completion: CommonTCallBack<Bool>
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            requestImagesData(readCache) { images in
                store.dispatch(action: SetList(list: images))
            }
        }
        
        private func requestImagesData(_ readCache: Bool = true, completion: @escaping CommonTCallBack<[GithubImage]>) -> Void {
            
            if readCache {
                CacheManager.fetchGithubImages { images in
                    appStore.isLoadingVisible = false
                    completion(images)
                }
                return
            }
            
            Networking<GithubImage>().request(API.repoImages) { data, cache, code in
                if code == MessageCode.notFound.rawValue {
                    requestCreateImageDir(completion: {
                        completion([])
                    })
                    return
                }
                
                if let list = data, !list.isEmpty {
                    let images = list.filter({$0.path.isImage()})
                    CacheManager.insertGithubImages(images: images, deleteNoFound: true) {
                        CacheManager.fetchGithubImages { localImages in
                            completion(localImages)
                        }
                    }
                } else {
                    completion([])
                }
            }
        }
        
        private func requestCreateImageDir(completion: @escaping CommonCallBack) -> Void {
            
            Networking<PushCommitModel>().request(API.createImagesDirectory) { data, cache, code in
                completion()
                if code != MessageCode.createSuccess.rawValue {
                    return
                }
                "ImageDir success".logI()
            }
            
        }
    }
}
