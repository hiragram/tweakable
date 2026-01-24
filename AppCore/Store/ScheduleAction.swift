import Foundation

/// スケジュール機能のアクション
public enum ScheduleAction: Sendable {
    // MARK: - User Actions

    /// ユーザー情報をセットアップ
    case setupUser(displayName: String)
    /// ユーザーのセットアップが完了
    case userSetupCompleted(User)
    /// 現在のユーザーを読み込み
    case loadCurrentUser
    /// ユーザーが読み込まれた
    case currentUserLoaded(User?)

    // MARK: - Group Actions

    /// グループを作成
    case createGroup(name: String)
    /// グループ作成が完了
    case groupCreated(UserGroup)
    /// 現在のグループを読み込み
    case loadCurrentGroup
    /// グループが読み込まれた
    case currentGroupLoaded(UserGroup?)
    /// グループオーナーかどうかを設定（後方互換用）
    case setIsGroupOwner(Bool)

    // MARK: - Multiple Groups Actions

    /// ユーザーの全グループを読み込み
    case loadGroups
    /// グループ一覧が読み込まれた
    case groupsLoaded([UserGroup])
    /// グループを選択（切り替え）
    case selectGroup(UUID)
    /// グループごとのオーナー情報を設定
    case setGroupOwnership(groupID: UUID, isOwner: Bool)

    // MARK: - Schedule Actions

    /// 週間スケジュールを初期化
    case initializeWeekSchedule(weekStartDate: Date)
    /// 週間スケジュールを読み込み
    case loadWeekSchedule(weekStartDate: Date)
    /// 週間スケジュールが読み込まれた
    case weekScheduleLoaded([DayScheduleEntry])
    /// エントリを更新（UI操作）
    case updateEntry(index: Int, dropOff: ScheduleStatus?, pickUp: ScheduleStatus?)
    /// スケジュールを送信
    case submitSchedule
    /// スケジュール送信が完了
    case submitCompleted([DayScheduleEntry])

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

    // MARK: - UI Actions

    /// 成功トーストを表示
    case showSuccessToast
    /// 成功トーストを非表示
    case hideSuccessToast

    // MARK: - Group Creation Actions

    /// グループ作成開始
    case startCreatingGroup
    /// グループ作成失敗
    case groupCreationFailed(String)

    // MARK: - Enabled Weekdays Actions

    /// 曜日の有効/無効を更新
    /// - weekday: Foundation.Calendarの曜日番号（1=日曜, 2=月曜, ..., 7=土曜）
    /// - enabled: 有効かどうか
    case updateEnabledWeekday(weekday: Int, enabled: Bool)

    // MARK: - Group Deletion Actions

    /// グループを削除（オーナーのみ可能）
    case deleteGroup(UUID)
    /// グループ削除中フラグを設定
    case setDeletingGroup(Bool)
    /// グループ削除が完了
    case groupDeleted(UUID)
    /// グループ削除が失敗
    case groupDeletionFailed(String)
}
