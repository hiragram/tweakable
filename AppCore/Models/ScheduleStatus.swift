import Foundation

/// スケジュールの状態を表すenum
/// - notSet: 未入力
/// - ok: 対応可能
/// - ng: 対応不可
public enum ScheduleStatus: Int, CaseIterable, Sendable {
    case notSet = 0
    case ok = 1
    case ng = 2

    /// 次の状態を返す（notSet → ok → ng → notSet）
    public func next() -> ScheduleStatus {
        switch self {
        case .notSet: return .ok
        case .ok: return .ng
        case .ng: return .notSet
        }
    }

    /// SupabaseScheduleStatusからの変換
    public init(from supabaseStatus: SupabaseScheduleStatus) {
        switch supabaseStatus {
        case .notSet: self = .notSet
        case .ok: self = .ok
        case .ng: self = .ng
        }
    }

    /// SupabaseScheduleStatusへの変換
    public var toSupabase: SupabaseScheduleStatus {
        switch self {
        case .notSet: return .notSet
        case .ok: return .ok
        case .ng: return .ng
        }
    }
}
