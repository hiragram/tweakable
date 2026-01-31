import Foundation
@testable import AppCore

/// ユニットテスト用のモックRevenueCatサービス（遅延なし）
final class MockRevenueCatServiceForTests: RevenueCatServiceProtocol, @unchecked Sendable {
    /// プレミアムユーザーとして振る舞うかどうか
    var isPremium: Bool = false

    func checkPremiumStatus() async throws -> Bool {
        return isPremium
    }

    func fetchPackages() async throws -> [SubscriptionPackage] {
        return []
    }

    func purchase(packageID: String) async throws -> PurchaseResult {
        return .success
    }

    func restorePurchases() async throws -> Bool {
        return isPremium
    }
}
