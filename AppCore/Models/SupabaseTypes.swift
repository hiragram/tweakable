import Foundation

// MARK: - Supabase Types (Dummy)
//
// These are dummy types kept for backward compatibility.
// The actual Supabase integration has been removed (standalone mode).

/// Supabase用プロフィール
public struct Profile: Codable, Equatable, Sendable {
    public let id: UUID
    public let displayName: String

    public init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

/// Supabase用ユーザーグループ
public struct SupabaseUserGroup: Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let ownerID: UUID

    public init(id: UUID, name: String, ownerID: UUID) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
    }
}

/// Supabase用スケジュールエントリ
public struct SupabaseScheduleEntry: Codable, Equatable, Sendable {
    public let id: UUID
    public let userID: UUID
    public let groupID: UUID
    public let date: Date
    public let dropOffStatus: String
    public let pickUpStatus: String

    public init(id: UUID, userID: UUID, groupID: UUID, date: Date, dropOffStatus: String, pickUpStatus: String) {
        self.id = id
        self.userID = userID
        self.groupID = groupID
        self.date = date
        self.dropOffStatus = dropOffStatus
        self.pickUpStatus = pickUpStatus
    }
}

/// Supabase用日別担当
public struct SupabaseDayAssignment: Codable, Equatable, Sendable {
    public let id: UUID
    public let groupID: UUID
    public let date: Date
    public let dropOffUserID: UUID?
    public let pickUpUserID: UUID?

    public init(id: UUID, groupID: UUID, date: Date, dropOffUserID: UUID?, pickUpUserID: UUID?) {
        self.id = id
        self.groupID = groupID
        self.date = date
        self.dropOffUserID = dropOffUserID
        self.pickUpUserID = pickUpUserID
    }
}

/// Supabase用天気地点
public struct SupabaseWeatherLocation: Codable, Equatable, Sendable {
    public let id: UUID
    public let groupID: UUID
    public let name: String
    public let latitude: Double
    public let longitude: Double

    public init(id: UUID, groupID: UUID, name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.groupID = groupID
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Supabase用招待コード
public struct SupabaseInviteCode: Codable, Equatable, Sendable {
    public let code: String
    public let groupID: UUID

    public init(code: String, groupID: UUID) {
        self.code = code
        self.groupID = groupID
    }
}

/// Supabaseストレージエラー
public enum SupabaseStorageError: Error {
    case unknown(String)
}

/// Supabase用スケジュールステータス
public enum SupabaseScheduleStatus: String, Codable, Sendable {
    case notSet = "not_set"
    case ok = "ok"
    case ng = "ng"
}
