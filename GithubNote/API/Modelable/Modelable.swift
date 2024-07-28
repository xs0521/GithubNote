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
    func data() -> Data?
    func filter() -> Bool
}

extension APIModelable {
    
    mutating func defultModel() -> Void {
        self.uuid = UUID().uuidString
    }
    
    func data() -> Data? {
        return ModelGenerator().toData(self)
    }
    
    func filter() -> Bool {
        false
    }
}

protocol Modelable {
    associatedtype AbstractType
    func handle(_ data: [String: Any]) -> AbstractType?
    func toData(_ model: AbstractType) -> Data?
}

extension Modelable {
    func handle(_ data: [String: Any]) -> AbstractType? {
        nil
    }
    func toData(_ model: AbstractType) -> Data? {
        nil
    }
}

//struct AnyModelable<T>: Modelable {
//    private let _handle: (_ data: [String: Any]) -> T?
//    
//    init<G: Modelable>(_ gen: G) where G.AbstractType == T {
//        _handle = gen.handle
//    }
//    
//    func handle(_ data: [String: Any]) -> T? {
//        return _handle(data)
//    }
//}

struct ModelGenerator<T: APIModelable>: Modelable {
    var snakeCase: Bool = false
    var filter: Bool = false
    typealias AbstractType = T
    func handle(_ data: [String: Any]) -> T? {
        let decoder = JSONDecoder()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            if snakeCase {
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            }
            var value = try decoder.decode(T.self, from: jsonData)
            value.defultModel()
            if filter {
                if !value.filter() {
                   return nil
                }
            }
            return value
        } catch {
            print(String(describing: error)) // <- ✅ Use this for debuging!
        }
        return nil
    }
    
    func toData(_ model: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            // 这里的 data 就是你的模型转换为 Data 的结果
            return data
        } catch {
            print("Error encoding model: \(error)")
        }
        return nil
    }
    
}


