import Foundation

/// ユーザー（個人）
public struct User: Identifiable, Sendable {
    public let id: UUID
    /// 非推奨: iCloud User Record ID（Supabase移行前の旧実装で使用）
    /// 現在は空文字列が設定される。Supabase移行完了後、既存データへの影響がないことを確認次第削除予定。
    public let iCloudUserID: String
    public var displayName: String
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        iCloudUserID: String = "",
        displayName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.iCloudUserID = iCloudUserID
        self.displayName = displayName
        self.createdAt = createdAt
    }
}
