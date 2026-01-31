import Foundation

/// RevenueCatサービスのエラー
public enum RevenueCatServiceError: Error, Sendable {
    case purchaseFailed(String)
    case restoreFailed(String)
    case networkError
    case unknown(String)
}

/// RevenueCatサービスのプロトコル（DI用）
public protocol RevenueCatServiceProtocol: Sendable {
    /// プレミアムステータスを確認
    /// - Returns: プレミアムユーザーかどうか
    func checkPremiumStatus() async throws -> Bool

    /// 利用可能なパッケージを取得
    /// - Returns: パッケージのリスト
    func fetchPackages() async throws -> [SubscriptionPackage]

    /// 購入を実行
    /// - Parameter packageID: 購入するパッケージID
    /// - Returns: 購入結果（成功、キャンセル、失敗）
    func purchase(packageID: String) async throws -> PurchaseResult

    /// 購入を復元
    /// - Returns: プレミアムユーザーかどうか
    func restorePurchases() async throws -> Bool
}

/// 購入結果
public enum PurchaseResult: Sendable {
    case success
    case cancelled
}
