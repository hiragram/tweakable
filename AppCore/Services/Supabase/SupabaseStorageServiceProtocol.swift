import Foundation

/// Supabaseストレージサービスプロトコル
/// CloudKit版と違い、RLSで権限制御されるためZone概念は不要
public protocol SupabaseStorageServiceProtocol: Sendable {
    // MARK: - Profile Operations

    /// プロフィールを保存（upsert）
    func saveProfile(_ profile: Profile) async throws -> Profile

    /// プロフィールを取得（ユーザーIDで）
    func fetchProfile(userID: UUID) async throws -> Profile?

    /// FCMトークンを保存
    func saveFCMToken(_ token: String, userID: UUID) async throws

    // MARK: - Group Operations

    /// グループを作成
    func createGroup(_ group: SupabaseUserGroup) async throws -> SupabaseUserGroup

    /// グループを取得（IDで）
    func fetchGroup(groupID: UUID) async throws -> SupabaseUserGroup?

    /// ユーザーが所属する承認済みグループを取得
    func fetchGroupsForUser(userID: UUID) async throws -> [SupabaseUserGroup]

    // MARK: - Membership Operations

    /// メンバーシップを作成（pending状態で）
    func createMembership(userID: UUID, groupID: UUID) async throws -> SupabaseGroupMembership

    /// メンバーシップのステータスを更新
    func updateMembershipStatus(membershipID: UUID, status: SupabaseMembershipStatus) async throws

    /// 承認待ちのメンバーシップを取得（グループオーナー用）
    func fetchPendingMemberships(groupID: UUID) async throws -> [SupabaseGroupMembership]

    /// グループの全メンバーシップを取得
    func fetchGroupMemberships(groupID: UUID) async throws -> [SupabaseGroupMembership]

    // MARK: - Schedule Entry Operations

    /// スケジュールエントリを保存（upsert）
    func saveScheduleEntry(_ entry: SupabaseScheduleEntry) async throws -> SupabaseScheduleEntry

    /// スケジュールエントリを複数保存
    func saveScheduleEntries(_ entries: [SupabaseScheduleEntry]) async throws -> [SupabaseScheduleEntry]

    /// 指定期間のスケジュールエントリを取得（グループ全体）
    func fetchScheduleEntries(groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseScheduleEntry]

    /// 指定ユーザーの指定期間のスケジュールエントリを取得
    func fetchScheduleEntries(userID: UUID, groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseScheduleEntry]

    // MARK: - Day Assignment Operations

    /// 担当割り当てを保存
    func saveDayAssignment(_ assignment: SupabaseDayAssignment) async throws -> SupabaseDayAssignment

    /// 担当割り当てを複数保存
    func saveDayAssignments(_ assignments: [SupabaseDayAssignment]) async throws -> [SupabaseDayAssignment]

    /// 指定期間の担当割り当てを取得
    func fetchDayAssignments(groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseDayAssignment]

    // MARK: - Weather Location Operations

    /// 天気地点を保存
    func saveWeatherLocation(_ location: SupabaseWeatherLocation) async throws -> SupabaseWeatherLocation

    /// 天気地点を取得
    func fetchWeatherLocations(groupID: UUID) async throws -> [SupabaseWeatherLocation]

    /// 天気地点を削除
    func deleteWeatherLocation(_ location: SupabaseWeatherLocation) async throws

    /// 天気地点を削除（IDで）
    func deleteWeatherLocation(locationID: UUID) async throws

    // MARK: - Invite Code Operations

    /// 招待コードを生成
    func createInviteCode(groupID: UUID, createdBy: UUID) async throws -> SupabaseInviteCode

    /// 招待コードを検証（未使用のコードを取得）
    func fetchInviteCode(code: String) async throws -> SupabaseInviteCode?

    /// 招待コードを使用済みにする
    func useInviteCode(code: String, usedBy: UUID) async throws -> SupabaseInviteCode

    /// 招待コード経由でメンバーを追加（approved状態で直接追加）
    func addMemberApproved(userID: UUID, groupID: UUID) async throws -> SupabaseGroupMembership
}

// MARK: - Supabase Models

/// Supabase用プロフィール（profiles テーブル）
public struct Profile: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID  // auth.users.id と同じ
    public var displayName: String
    public var fcmToken: String?
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(id: UUID, displayName: String, fcmToken: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.displayName = displayName
        self.fcmToken = fcmToken
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case fcmToken = "fcm_token"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase用ユーザーグループ（user_groups テーブル）
public struct SupabaseUserGroup: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public var name: String
    public let ownerID: UUID
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(id: UUID, name: String, ownerID: UUID, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case ownerID = "owner_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// メンバーシップステータス
public enum SupabaseMembershipStatus: String, Sendable, Codable {
    case pending
    case approved
    case rejected
}

/// Supabase用グループメンバーシップ（group_memberships テーブル）
public struct SupabaseGroupMembership: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let userID: UUID
    public let groupID: UUID
    public var status: SupabaseMembershipStatus
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(id: UUID, userID: UUID, groupID: UUID, status: SupabaseMembershipStatus, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.userID = userID
        self.groupID = groupID
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case groupID = "group_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase用スケジュールエントリ（schedule_entries テーブル）
public struct SupabaseScheduleEntry: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let userID: UUID
    public let groupID: UUID
    public let date: Date
    public var dropOffStatus: SupabaseScheduleStatus
    public var pickUpStatus: SupabaseScheduleStatus
    public var note: String?
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(
        id: UUID,
        userID: UUID,
        groupID: UUID,
        date: Date,
        dropOffStatus: SupabaseScheduleStatus = .notSet,
        pickUpStatus: SupabaseScheduleStatus = .notSet,
        note: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userID = userID
        self.groupID = groupID
        self.date = date
        self.dropOffStatus = dropOffStatus
        self.pickUpStatus = pickUpStatus
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case groupID = "group_id"
        case date
        case dropOffStatus = "drop_off_status"
        case pickUpStatus = "pick_up_status"
        case note
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase用スケジュールステータス
public enum SupabaseScheduleStatus: String, Sendable, Codable {
    case notSet = "not_set"
    case ok = "ok"
    case ng = "ng"
}

/// Supabase用担当割り当て（day_assignments テーブル）
public struct SupabaseDayAssignment: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let groupID: UUID
    public let date: Date
    public var dropOffUserID: UUID?
    public var pickUpUserID: UUID?
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(
        id: UUID,
        groupID: UUID,
        date: Date,
        dropOffUserID: UUID? = nil,
        pickUpUserID: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.groupID = groupID
        self.date = date
        self.dropOffUserID = dropOffUserID
        self.pickUpUserID = pickUpUserID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case date
        case dropOffUserID = "drop_off_user_id"
        case pickUpUserID = "pick_up_user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase用天気地点（weather_locations テーブル）
public struct SupabaseWeatherLocation: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let groupID: UUID
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(
        id: UUID,
        groupID: UUID,
        name: String,
        latitude: Double,
        longitude: Double,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.groupID = groupID
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case groupID = "group_id"
        case name
        case latitude
        case longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Supabase用招待コード（invite_codes テーブル）
public struct SupabaseInviteCode: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let code: String
    public let groupID: UUID
    public let createdBy: UUID
    public var usedBy: UUID?
    public var usedAt: Date?
    public var createdAt: Date?

    public init(
        id: UUID,
        code: String,
        groupID: UUID,
        createdBy: UUID,
        usedBy: UUID? = nil,
        usedAt: Date? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.groupID = groupID
        self.createdBy = createdBy
        self.usedBy = usedBy
        self.usedAt = usedAt
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case groupID = "group_id"
        case createdBy = "created_by"
        case usedBy = "used_by"
        case usedAt = "used_at"
        case createdAt = "created_at"
    }
}
