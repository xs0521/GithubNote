//
//  String+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/2.
//

import Foundation

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
