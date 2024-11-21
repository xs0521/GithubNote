//
//  Data+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/25.
//

import Foundation

extension Data {
    
    func anyObj() -> Any? {
        do {
            let obj = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
            return obj
        } catch {
            print("Error encoding model: \(error)")
        }
        return nil
    }
}

extension Data {
    // 基于文件的魔数判断 MIME 类型
    func mimeTypeMagicBytes() -> String {
        let mimeType = Swime.mimeType(data: self)
        return mimeType?.mime ?? "application/octet-stream"
    }
}
