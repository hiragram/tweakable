import Foundation

// MARK: - Invitation State (for inviting members)

/// State for creating an invitation
public enum InvitationState: Equatable, Sendable {
    case idle
    case creating
    case success(url: URL)
    case error(message: String)
}

// MARK: - Accept Invitation State (for accepting invitations)

/// State for accepting an invitation
public enum AcceptInvitationState: Equatable, Sendable {
    case idle
    case pending
    case accepting
    case success
    case error(message: String)
}

// MARK: - Invitation Info

/// Information about the pending invitation
public struct InvitationInfo: Equatable, Sendable, Identifiable {
    public let id = UUID()
    public let inviterName: String
    public let groupName: String?

    public init(inviterName: String, groupName: String?) {
        self.inviterName = inviterName
        self.groupName = groupName
    }

    // Identifiable用のidを除外してEquatableを手動実装
    public static func == (lhs: InvitationInfo, rhs: InvitationInfo) -> Bool {
        lhs.inviterName == rhs.inviterName && lhs.groupName == rhs.groupName
    }
}

// MARK: - Group Member

/// グループメンバー情報
public struct GroupMember: Equatable, Sendable, Identifiable {
    public var id: String { participantID }
    /// CKShare参加者のuserRecordID.recordName
    public let participantID: String
    /// メンバーの表示名
    public let displayName: String
    /// オーナーかどうか
    public let isOwner: Bool

    public init(participantID: String, displayName: String, isOwner: Bool) {
        self.participantID = participantID
        self.displayName = displayName
        self.isOwner = isOwner
    }
}

// MARK: - Join Request

/// 参加リクエスト情報（オーナー側で管理）
/// CloudKit公開共有では参加者は自動的に追加されるため、これは実質的に「新しいメンバー通知」
public struct JoinRequest: Equatable, Sendable, Identifiable {
    public var id: String { participantID }
    /// CKShare参加者のuserRecordID.recordName
    public let participantID: String
    public let userName: String

    public init(participantID: String, userName: String) {
        self.participantID = participantID
        self.userName = userName
    }
}

// MARK: - Sharing State

/// 共有機能の状態
public struct SharingState: Equatable, Sendable {
    // MARK: - Legacy Properties (kept for backward compatibility)

    /// 共有URLを作成中かどうか
    public var isCreatingShare: Bool = false

    /// 共有を受け入れ中かどうか
    public var isAcceptingShare: Bool = false

    /// 作成された共有URL
    public var shareURL: URL?

    /// 共有されたグループ
    public var sharedGroup: UserGroup?

    /// 共有グループに参加済みかどうか
    public var hasJoinedSharedGroup: Bool = false

    /// エラーメッセージ
    public var sharingError: String?

    // MARK: - New State Properties

    /// State for creating invitations
    public var invitationState: InvitationState = .idle

    /// State for accepting invitations
    public var acceptInvitationState: AcceptInvitationState = .idle

    /// Pending invitation info (when accepting)
    public var pendingInvitationInfo: InvitationInfo?

    // MARK: - Join Request Management (Owner side)

    /// 承認待ちの参加リクエスト一覧
    public var pendingJoinRequests: [JoinRequest] = []

    /// 現在処理中のリクエストID（participantID）
    public var processingRequestID: String?

    // MARK: - Member List

    /// グループメンバー一覧
    public var members: [GroupMember] = []

    /// メンバー一覧を読み込み中かどうか
    public var isLoadingMembers: Bool = false

    // MARK: - Approval Status (for participants)

    /// 現在のユーザーが承認済みメンバーかどうか（参加者用）
    /// オーナーは常にtrue、参加者はapprovedUserIDsに含まれていればtrue
    public var isApprovedMember: Bool = true

    /// 承認状態を確認中かどうか（参加者用）
    public var isCheckingApprovalStatus: Bool = false

    // MARK: - Invite Code (Supabase)

    /// 招待コードを生成中かどうか
    public var isCreatingInviteCode: Bool = false

    /// 生成された招待コード
    public var generatedInviteCode: String?

    /// 入力された招待コード
    public var inviteCodeInput: String = ""

    /// 招待コードで参加中かどうか
    public var isJoiningWithCode: Bool = false

    /// 参加したSupabaseグループ
    public var joinedSupabaseGroup: SupabaseUserGroup?

    public init() {}
}
