//
//  Model.swift
//  GithubNote
//
//  Created by xs0521 on 2024/7/20.
//

import Foundation

protocol APIModelable: Codable {
    var uuid: String? { get set }
    mutating func defultModel() -> Void
}

extension APIModelable {
    mutating func defultModel() -> Void {
        self.uuid = UUID().uuidString
    }
}

protocol Modelable {
    associatedtype AbstractType
    func handle(_ data: [String: Any]) -> AbstractType?
}

extension Modelable {
    func handle(_ data: [String: Any]) -> AbstractType? {
        nil
    }
}

struct AnyModelable<T>: Modelable {
    private let _handle: (_ data: [String: Any]) -> T?
    
    init<G: Modelable>(_ gen: G) where G.AbstractType == T {
        _handle = gen.handle
    }
    
    func handle(_ data: [String: Any]) -> T? {
        return _handle(data)
    }
}

struct ModelGenerator<T: APIModelable>: Modelable {
    var convertFromSnakeCase: Bool = false
    typealias AbstractType = T
    func handle(_ data: [String: Any]) -> T? {
        let decoder = JSONDecoder()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            if convertFromSnakeCase {
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            }
            var value = try decoder.decode(T.self, from: jsonData)
            value.defultModel()
            return value
        } catch {
            print(String(describing: error)) // <- ✅ Use this for debuging!
        }
        return nil
    }
}


