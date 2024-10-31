//
//  ImagesActions.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/30.
//

import Foundation
import SwiftUIFlux
import SwiftUI

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
    
    struct Delete: AsyncAction {
        
        let item: GithubImage
        let completion: CommonTCallBack<Bool>
        
        func execute(state: SwiftUIFlux.FluxState?, dispatch: @escaping SwiftUIFlux.DispatchFunction) {
            deleteFile(item, completion)
        }
        
        private func deleteFile(_ item: GithubImage, _ completion: @escaping CommonTCallBack<Bool>) -> Void {
            
            Networking<PushCommitModel>().request(API.deleteImage(filePath: item.path, sha: item.sha)) { _, cache, code in
                if code == MessageCode.success.rawValue {
                    CacheManager.deleteGithubImage(item.url) {
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    struct Copy: Action {
        
        let url: String
        
        init(url: String) {
            self.url = url
            copyAction(url)
        }
        
        fileprivate func copyAction(_ url: String) -> Void {
            let content = """
            <img src="\(url)" alt="alt text" width="300" height="200">
            """
            
    #if MOBILE
    #else
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(content, forType: .string)
    #endif
            
        }
    }
}
