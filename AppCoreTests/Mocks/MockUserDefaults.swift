import Foundation
@testable import AppCore

/// テスト用のUserDefaultsモック
final class MockUserDefaults: UserDefaultsProtocol, @unchecked Sendable {
    // MARK: - Storage

    var storage: [String: Any] = [:]

    // MARK: - Call Tracking

    var boolCallCount = 0
    var setCallCount = 0

    // MARK: - UserDefaultsProtocol

    func bool(forKey defaultName: String) -> Bool {
        boolCallCount += 1
        return storage[defaultName] as? Bool ?? false
    }

    func set(_ value: Bool, forKey defaultName: String) {
        setCallCount += 1
        storage[defaultName] = value
    }
}
