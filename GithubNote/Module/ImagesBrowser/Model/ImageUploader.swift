//
//  ImageUploader.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/18.
//

import Foundation
import SDWebImage

class ImageUploader {
    
    static let shared = ImageUploader()
    
    func uploadImages(urls: [URL], completion: @escaping CommonTCallBack<Bool>) -> Void {
        
        let semaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue.global(qos: .userInitiated)
        let dispatchGroup = DispatchGroup()
        for url in urls {
            _ = url.startAccessingSecurityScopedResource()
            dispatchGroup.enter()
            queue.async(execute: {
                semaphore.wait()
                "#image upload# \(url)".logI()
                self.uploadImage(filePath: url, completion: { (_) in
                    url.stopAccessingSecurityScopedResource()
                    semaphore.signal()
                    dispatchGroup.leave()
                })
            })
            
        }
        dispatchGroup.notify(queue: .main) {
            completion(true)
        }
    }
    
    private func uploadImage(filePath: URL, completion: @escaping CommonTCallBack<Bool>) -> Void {
        
        let imageData = try? Data(contentsOf: filePath)
        guard let imageData = imageData, !imageData.isEmpty else { return }
        let imageBase64 = imageData.base64EncodedString()
        
        let pathExtension = filePath.pathExtension
        let fileName = self.fileName() + ".\(pathExtension)"
        
        Networking<PushCommitModel>().uploadImage(API.updateImage(imageBase64: imageBase64, fileName: fileName)) { _ in
        } completionModelHandler: { data, cache, code in
            
            if code != MessageCode.createSuccess.rawValue {
                completion(false)
                return
            }
            
            guard let item = data?.first else {
                completion(false)
                return
            }
            
            let content = item.content
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            do {
                let data = try encoder.encode(content)
                let item = try decoder.decode(GithubImage.self, from: data)
                let cache = SDWebImageManager.defaultImageCache as! SDImageCache
                "#image# save \(item.imageUrl())".logI()
                cache.storeImageData(imageData, forKey: item.imageUrl(), completion: {
                    CacheManager.insert(items: [item]) {
                        NotificationCenter.default.post(name: NSNotification.Name.appendImagesNotification, object: item)
                        completion(true)
                    }
                })
            } catch let err {
                completion(false)
                print(err)
            }
        }
    }
    
    private func fileName() -> String {
        return TimeManager.shared.titleFormatter.string(from: Date())
    }
}
