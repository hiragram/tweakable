import Foundation

/// 共有機能のアクション
public enum SharingAction: Sendable {
    // MARK: - Share Creation

    /// 共有の作成を開始（既存があればそれを返す）
    case startCreatingShare

    /// 共有が作成された
    case shareCreated(url: URL)

    /// 共有の作成に失敗
    case shareCreationFailed(error: String)

    /// 招待状態をリセット
    case resetInvitation

    // MARK: - Share Acceptance

    /// 招待情報を設定（招待リンクを開いた時）
    case setInvitationInfo(InvitationInfo)

    /// 共有の受け入れを開始
    case startAcceptingShare

    /// 共有を受け入れた
    case shareAccepted(group: UserGroup)

    /// 共有の受け入れに失敗
    case shareAcceptanceFailed(error: String)

    /// 招待受け入れ状態をリセット
    case resetAcceptInvitation

    // MARK: - Error Handling

    /// エラーをクリア
    case clearError

    // MARK: - Join Request Management (Owner side)

    /// 承認待ちの参加リクエストを設定
    case setPendingJoinRequests([JoinRequest])

    /// リクエストの承認を開始（participantID = userRecordID.recordName）
    case startApprovingRequest(participantID: String)

    /// リクエストが承認された
    case requestApproved(participantID: String)

    /// リクエストの却下を開始
    case startRejectingRequest(participantID: String)

    /// リクエストが却下された
    case requestRejected(participantID: String)

    /// リクエスト処理に失敗
    case requestProcessingFailed(error: String)

    /// 承認待ちリクエストを読み込み
    case loadPendingJoinRequests

    // MARK: - Member List

    /// メンバー一覧を読み込み
    case loadMembers

    /// メンバー一覧の読み込みを開始
    case startLoadingMembers

    /// メンバー一覧を設定
    case setMembers([GroupMember])

    /// メンバー一覧の読み込みに失敗
    case loadMembersFailed(error: String)

    // MARK: - Approval Status

    /// 承認状態を設定
    case setApprovalStatus(isApproved: Bool)

    /// 承認状態を再チェック（再読み込み）
    case checkApprovalStatus

    // MARK: - Invite Code (Supabase)

    /// 招待コードの生成を開始
    case startCreatingInviteCode

    /// 招待コードが生成された
    case inviteCodeCreated(code: String)

    /// 招待コードの生成に失敗
    case inviteCodeCreationFailed(error: String)

    /// 入力された招待コードを設定
    case setInviteCodeInput(String)

    /// 招待コードで参加を開始
    case startJoiningWithCode

    /// 招待コードで参加成功
    case joinedWithCode(group: SupabaseUserGroup)

    /// 招待コードで参加失敗
    case joinWithCodeFailed(error: String)

    /// 生成された招待コードをクリア
    case clearGeneratedInviteCode

    /// 招待コード関連の状態をリセット
    case resetInviteCodeState
}
