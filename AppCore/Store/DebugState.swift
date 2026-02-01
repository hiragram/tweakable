#if DEBUG
import Foundation

/// デバッグ機能の状態
public struct DebugState: Equatable, Sendable {
    /// RevenueCatのStore種別
    public enum RevenueCatStore: String, Equatable, Sendable {
        case testStore
        case appStore
    }

    /// 現在のRevenueCat Store
    public var currentStore: RevenueCatStore = .testStore

    /// 処理中かどうか
    public var isProcessing: Bool = false

    /// 再起動が必要かどうか（Store切り替え後）
    public var requiresRestart: Bool = false

    /// エラーメッセージ
    public var errorMessage: String?

    public init() {}
}
#endif
