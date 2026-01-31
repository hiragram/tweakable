import Foundation

/// サブスクリプション機能の状態
public struct SubscriptionState: Equatable, Sendable {
    /// プレミアムユーザーかどうか
    public var isPremium: Bool = false

    /// サブスクリプション情報を読み込み中かどうか
    public var isLoading: Bool = false

    /// 購入処理中かどうか
    public var isPurchasing: Bool = false

    /// 復元処理中かどうか
    public var isRestoring: Bool = false

    /// エラーメッセージ
    public var errorMessage: String?

    /// 利用可能なパッケージ（Paywall表示用）
    public var availablePackages: [SubscriptionPackage] = []

    /// Paywallを表示中かどうか
    public var showsPaywall: Bool = false

    public init() {}
}

/// サブスクリプションパッケージ（RevenueCat Package のラッパー）
public struct SubscriptionPackage: Equatable, Sendable, Identifiable {
    public let id: String
    public let localizedTitle: String
    public let localizedPriceString: String
    public let productIdentifier: String

    public init(
        id: String,
        localizedTitle: String,
        localizedPriceString: String,
        productIdentifier: String
    ) {
        self.id = id
        self.localizedTitle = localizedTitle
        self.localizedPriceString = localizedPriceString
        self.productIdentifier = productIdentifier
    }
}
