import Foundation

/// サブスクリプション機能のアクション
public enum SubscriptionAction: Sendable {
    // MARK: - Initialization

    /// サブスクリプション状態を読み込む（アプリ起動時）
    case loadSubscriptionStatus

    /// サブスクリプション状態読み込み完了
    case subscriptionStatusLoaded(isPremium: Bool)

    /// サブスクリプション状態読み込み失敗
    case subscriptionStatusLoadFailed(String)

    // MARK: - Paywall

    /// Paywallを表示
    case showPaywall

    /// Paywallを閉じる
    case hidePaywall

    /// 利用可能なパッケージを読み込む
    case loadPackages

    /// パッケージ読み込み完了
    case packagesLoaded([SubscriptionPackage])

    /// パッケージ読み込み失敗
    case packagesLoadFailed(String)

    // MARK: - Purchase

    /// 購入を開始
    case purchase(packageID: String)

    /// 購入成功
    case purchaseSucceeded

    /// 購入失敗
    case purchaseFailed(String)

    /// 購入キャンセル
    case purchaseCancelled

    // MARK: - Restore

    /// 購入を復元
    case restorePurchases

    /// 復元成功
    case restoreSucceeded(isPremium: Bool)

    /// 復元失敗
    case restoreFailed(String)

    // MARK: - Clear

    /// エラーをクリア
    case clearError
}
