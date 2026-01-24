import Foundation

/// メンバーシップのステータス
public enum MembershipStatus: String, Sendable, Equatable, CaseIterable {
    /// 承認待ち（招待リンクを踏んだがオーナー未承認）
    case pending = "pending"
    /// 承認済み（正式メンバー）
    case approved = "approved"
    /// 拒否された
    case rejected = "rejected"
}

/// ユーザーとグループの所属関係（中間テーブル）
public struct UserGroupMembership: Identifiable, Sendable {
    public let id: UUID
    public let userID: UUID
    public let userGroupID: UUID
    public let status: MembershipStatus
    public let createdAt: Date?

    public init(
        id: UUID = UUID(),
        userID: UUID,
        userGroupID: UUID,
        status: MembershipStatus = .approved,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.userID = userID
        self.userGroupID = userGroupID
        self.status = status
        self.createdAt = createdAt
    }
}
