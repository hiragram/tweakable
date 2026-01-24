import Foundation

/// UserDefaultsの依存性注入用プロトコル
public protocol UserDefaultsProtocol: Sendable {
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
}

/// UserDefaults.standardをプロトコルに適合させる
extension UserDefaults: UserDefaultsProtocol, @unchecked Sendable {}
