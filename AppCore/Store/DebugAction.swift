#if DEBUG
import Foundation

/// デバッグ機能のアクション
public enum DebugAction: Sendable {
    // MARK: - RevenueCat Store

    /// RevenueCat Storeを切り替える
    case switchStore(useTestStore: Bool)

    /// Store切り替え完了（再起動が必要）
    case storeSwitched

    // MARK: - RevenueCat User

    /// RevenueCatユーザーをリセットする
    case resetUser

    /// ユーザーリセット完了
    case userReset

    // MARK: - Data

    /// 全データを削除する
    case deleteAllData

    /// データ削除完了
    case dataDeleted

    /// シードデータフラグをリセットする
    case resetSeedData

    /// シードデータリセット完了
    case seedDataReset

    // MARK: - Error

    /// 操作失敗
    case operationFailed(String)

    /// エラーをクリア
    case clearError
}
#endif
