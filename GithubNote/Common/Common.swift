//
//  Common.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/15.
//

import Foundation

typealias CommonCallBack = () -> ()
typealias CommonTCallBack<T> = (T) -> ()
typealias RequestCallBack = (_ success: Bool, _ more: Bool) -> ()
