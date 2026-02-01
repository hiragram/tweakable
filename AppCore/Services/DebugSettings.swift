#if DEBUG
import Foundation

/// デバッグ設定を管理するシングルトン
/// UserDefaultsに永続化し、アプリ再起動後も設定を維持する
@MainActor
public final class DebugSettings {
    public static let shared = DebugSettings()

    private static let useTestStoreKey = "debug.revenueCat.useTestStore"

    private init() {}

    /// RevenueCatでTest Storeを使用するかどうか
    /// デフォルトはtrue（DEBUGビルドではTest Store）
    public var useTestStore: Bool {
        get {
            // キーが存在しない場合はtrue（Test Store）をデフォルトとする
            if UserDefaults.standard.object(forKey: Self.useTestStoreKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Self.useTestStoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.useTestStoreKey)
        }
    }
}
#endif
