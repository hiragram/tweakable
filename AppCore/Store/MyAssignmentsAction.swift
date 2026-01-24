import Foundation

/// 自分の担当一覧画面のアクション
public enum MyAssignmentsAction: Sendable {
    /// 自分の担当を読み込み開始
    case loadMyAssignments

    /// 自分の担当が読み込まれた
    case myAssignmentsLoaded([MyAssignmentItem])

    /// 読み込み中フラグを設定
    case setLoading(Bool)

    /// エラーが発生
    case errorOccurred(String)

    /// エラーをクリア
    case clearError
}
