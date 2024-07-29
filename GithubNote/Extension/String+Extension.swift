//
//  String+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/2.
//

import Foundation
import CommonCrypto

extension String {
    
    func toTitle() -> String {
        var value = trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        value = value.trimmingCharacters(in: .whitespaces)
        
        if value.count > 20 {
            value = String(value.prefix(20))
        }
        let values = value.components(separatedBy: "\n")
        if values.count > 0 {
            value = values.first ?? value
        }
        return value
    }
    
    @discardableResult
    func p() -> Self {
        print("#GN# \(self)")
        return self
    }
    
    func encrypt(_ maxLength: Int) -> String {
        let starString = String(repeating: "*", count: self.count).prefix(maxLength)
        return String(starString)
    }
}

extension String {
    
    func MD5() -> String {
        guard self.count > 0 else {
            fatalError("md5 error")
        }
        let cCharArray = self.cString(using: .utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cCharArray, CC_LONG(cCharArray!.count - 1), &uint8Array)
        let data = Data(bytes: &uint8Array, count: Int(CC_MD5_DIGEST_LENGTH))
        let base64String = data.base64EncodedString()
        return base64String
    }
}


extension String {
    
    func isImage() -> Bool {
        guard let suffix = self.split(separator: ".").last?.lowercased() else { return false }
        return ["jpeg","jpg", "png", "tiff", "gif", "webp", "heic", "avif"].contains(suffix)
    }
}
