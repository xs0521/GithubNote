//
//  Data+Extension.swift
//  GithubNote
//
//  Created by luoshuai on 2024/7/25.
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
