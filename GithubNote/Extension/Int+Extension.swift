//
//  Int+Extension.swift
//  GithubNote
//
//  Created by xs0521 on 2024/10/16.
//

import Foundation

extension Int {
    
    func localTime() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        return TimeManager.shared.formatter.string(from: date)
    }
}
