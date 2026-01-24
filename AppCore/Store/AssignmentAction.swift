import Foundation

/// 担当者割り当て機能のアクション
public enum AssignmentAction: Sendable {
    // MARK: - Group Actions

    /// 現在のグループIDを設定
    case setCurrentGroupID(UUID)

    // MARK: - Assignment Actions

    /// 週間担当を初期化
    case initializeWeekAssignments(weekStartDate: Date)
    /// 週間担当を読み込み
    case loadWeekAssignments(weekStartDate: Date)
    /// 週間担当が読み込まれた
    case weekAssignmentsLoaded([DayAssignment])
    /// 担当を更新（UI操作）
    case updateAssignment(index: Int, dropOffUserID: UUID?, pickUpUserID: UUID?)
    /// 送り担当をクリア
    case clearDropOffAssignment(index: Int)
    /// 迎え担当をクリア
    case clearPickUpAssignment(index: Int)
    /// 担当を送信
    case submitAssignments
    /// 担当送信が完了
    case submitCompleted([DayAssignment])

    // MARK: - Loading Actions

    /// ローディング開始
    case setLoading(Bool)
    /// 保存中フラグを設定
    case setSaving(Bool)

    // MARK: - Error Actions

    /// エラーが発生
    case errorOccurred(String)
    /// エラーをクリア
    case clearError
}
