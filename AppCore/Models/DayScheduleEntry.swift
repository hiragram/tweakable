import Foundation

/// 1日分のスケジュールエントリ
/// あるユーザーの、あるグループに対する、ある日の参加可否入力を表す
public struct DayScheduleEntry: Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    public let userID: UUID
    public let userGroupID: UUID
    public var dropOffStatus: ScheduleStatus
    public var pickUpStatus: ScheduleStatus

    public init(
        id: UUID = UUID(),
        date: Date,
        userID: UUID,
        userGroupID: UUID,
        dropOffStatus: ScheduleStatus = .notSet,
        pickUpStatus: ScheduleStatus = .notSet
    ) {
        self.id = id
        // 日付を正規化（その日の00:00:00に統一）
        self.date = Calendar.current.startOfDay(for: date)
        self.userID = userID
        self.userGroupID = userGroupID
        self.dropOffStatus = dropOffStatus
        self.pickUpStatus = pickUpStatus
    }

    /// 曜日を返す（例: "月", "火" / "Mon", "Tue"）
    public var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    /// 月/日を返す（例: "1/5", "12/25"）
    public var monthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
