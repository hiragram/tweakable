import Foundation

/// スケジュール機能の状態
public struct ScheduleState: Equatable, Sendable {
    // MARK: - User Info
    public var currentUser: User?

    // MARK: - Group Info
    public var currentGroup: UserGroup?
    /// 複数グループ対応: ユーザーが所属する全グループ
    public var groups: [UserGroup] = []
    /// グループごとのオーナー情報（グループID → オーナーかどうか）
    public var groupOwnership: [UUID: Bool] = [:]
    /// 現在のユーザーがグループのオーナーかどうか（CloudKit共有用）
    /// Note: 後方互換のため残しているが、isCurrentGroupOwnerを使用することを推奨
    public var isGroupOwner: Bool = true

    /// 現在選択中のグループのオーナーかどうか（computed property）
    public var isCurrentGroupOwner: Bool {
        guard let groupID = currentGroup?.id else { return true }
        return groupOwnership[groupID] ?? true
    }

    // MARK: - Week Entries
    public var weekEntries: [DayScheduleEntry] = []
    public var weekStartDate: Date = Date()

    // MARK: - Loading State
    public var isLoading = false
    public var isSaving = false

    // MARK: - Error
    public var errorMessage: String?

    // MARK: - Status
    public var isEditable = true

    // MARK: - UI State
    public var showSuccessToast = false

    // MARK: - Group Creation State
    public var isCreatingGroup = false

    // MARK: - Group Deletion State
    public var isDeletingGroup = false

    // MARK: - Computed Properties

    /// 全て入力済みかどうか
    public var isAllFilled: Bool {
        weekEntries.allSatisfy { $0.dropOffStatus != .notSet && $0.pickUpStatus != .notSet }
    }

    /// 未入力件数
    public var remainingCount: Int {
        weekEntries.reduce(0) { count, entry in
            count + (entry.dropOffStatus == .notSet ? 1 : 0) + (entry.pickUpStatus == .notSet ? 1 : 0)
        }
    }

    public init() {}
}

// MARK: - User Equatable

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.displayName == rhs.displayName
    }
}

// MARK: - DayScheduleEntry Equatable

extension DayScheduleEntry: Equatable {
    public static func == (lhs: DayScheduleEntry, rhs: DayScheduleEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.userID == rhs.userID &&
        lhs.userGroupID == rhs.userGroupID &&
        lhs.dropOffStatus == rhs.dropOffStatus &&
        lhs.pickUpStatus == rhs.pickUpStatus
    }
}

// MARK: - UserGroup Equatable

extension UserGroup: Equatable {
    public static func == (lhs: UserGroup, rhs: UserGroup) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

