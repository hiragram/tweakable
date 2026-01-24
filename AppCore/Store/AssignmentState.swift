import Foundation

/// 担当者割り当て機能の状態
public struct AssignmentState: Equatable, Sendable {
    // MARK: - Group Info
    public var currentGroupID: UUID?

    // MARK: - Week Assignments
    public var weekAssignments: [DayAssignment] = []
    public var weekStartDate: Date = Calendar.current.startOfDay(for: Date())

    // MARK: - Loading State
    public var isLoading = false
    public var isSaving = false

    // MARK: - Error
    public var errorMessage: String?

    public init() {}
}

// MARK: - DayAssignment Equatable

extension DayAssignment: Equatable {
    public static func == (lhs: DayAssignment, rhs: DayAssignment) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.userGroupID == rhs.userGroupID &&
        lhs.assignedDropOffUserID == rhs.assignedDropOffUserID &&
        lhs.assignedPickUpUserID == rhs.assignedPickUpUserID
    }
}
