import Foundation

/// UIテスト用のモックRevenueCatサービス
public final class MockRevenueCatService: RevenueCatServiceProtocol, @unchecked Sendable {
    /// プレミアムユーザーとして振る舞うかどうか
    private let isPremium: Bool

    public init(isPremium: Bool = false) {
        self.isPremium = isPremium
    }

    public func checkPremiumStatus() async throws -> Bool {
        // UIテスト用の遅延（100ms）
        try await Task.sleep(nanoseconds: 100_000_000)
        return isPremium
    }

    public func fetchPackages() async throws -> [SubscriptionPackage] {
        // UIテスト用の遅延（100ms）
        try await Task.sleep(nanoseconds: 100_000_000)
        return [
            SubscriptionPackage(
                id: "$rc_monthly",
                localizedTitle: "Premium Monthly",
                localizedPriceString: "$4.99/month",
                productIdentifier: "premium_1month"
            )
        ]
    }

    public func purchase(packageID: String) async throws -> PurchaseResult {
        // UIテスト用の遅延（200ms）
        try await Task.sleep(nanoseconds: 200_000_000)
        return .success
    }

    public func restorePurchases() async throws -> Bool {
        // UIテスト用の遅延（200ms）
        try await Task.sleep(nanoseconds: 200_000_000)
        return isPremium
    }
}
