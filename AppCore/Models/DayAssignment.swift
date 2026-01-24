import Foundation

/// 1日分の担当者割り当て
/// あるグループに対する、ある日の送り/迎え担当者を表す
public struct DayAssignment: Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    public let userGroupID: UUID
    public var assignedDropOffUserID: UUID?  // 送りの担当者
    public var assignedPickUpUserID: UUID?   // 迎えの担当者

    public init(
        id: UUID = UUID(),
        date: Date,
        userGroupID: UUID,
        assignedDropOffUserID: UUID? = nil,
        assignedPickUpUserID: UUID? = nil
    ) {
        self.id = id
        // 日付を正規化（その日の00:00:00に統一）
        self.date = Calendar.current.startOfDay(for: date)
        self.userGroupID = userGroupID
        self.assignedDropOffUserID = assignedDropOffUserID
        self.assignedPickUpUserID = assignedPickUpUserID
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
