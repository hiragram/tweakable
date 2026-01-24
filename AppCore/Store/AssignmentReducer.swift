import Foundation

/// 担当者割り当て機能のReducer（純粋関数）
public enum AssignmentReducer {
    /// 状態を更新する純粋関数
    /// - Parameters:
    ///   - state: 現在の状態（inout）
    ///   - action: 実行するアクション
    public static func reduce(state: inout AssignmentState, action: AssignmentAction) {
        switch action {
        // MARK: - Group Actions

        case .setCurrentGroupID(let groupID):
            state.currentGroupID = groupID

        // MARK: - Assignment Actions

        case .initializeWeekAssignments(let weekStartDate):
            state.weekStartDate = weekStartDate
            guard let userGroupID = state.currentGroupID else { return }

            let calendar = Calendar.current
            state.weekAssignments = (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: weekStartDate) else {
                    return nil
                }
                return DayAssignment(date: date, userGroupID: userGroupID)
            }

        case .loadWeekAssignments(let weekStartDate):
            state.weekStartDate = weekStartDate
            state.isLoading = true

        case .weekAssignmentsLoaded(let assignments):
            state.isLoading = false
            if assignments.isEmpty {
                // エントリがなければ何もしない
            } else {
                state.weekAssignments = mergeAssignments(
                    existing: assignments,
                    weekStartDate: state.weekStartDate,
                    userGroupID: state.currentGroupID
                )
            }

        case .updateAssignment(let index, let dropOffUserID, let pickUpUserID):
            guard index < state.weekAssignments.count else { return }

            if let dropOffUserID = dropOffUserID {
                state.weekAssignments[index].assignedDropOffUserID = dropOffUserID
            }
            if let pickUpUserID = pickUpUserID {
                state.weekAssignments[index].assignedPickUpUserID = pickUpUserID
            }

        case .clearDropOffAssignment(let index):
            guard index < state.weekAssignments.count else { return }
            state.weekAssignments[index].assignedDropOffUserID = nil

        case .clearPickUpAssignment(let index):
            guard index < state.weekAssignments.count else { return }
            state.weekAssignments[index].assignedPickUpUserID = nil

        case .submitAssignments:
            state.isSaving = true

        case .submitCompleted(let assignments):
            state.isSaving = false
            state.weekAssignments = assignments

        // MARK: - Loading Actions

        case .setLoading(let isLoading):
            state.isLoading = isLoading

        case .setSaving(let isSaving):
            state.isSaving = isSaving

        // MARK: - Error Actions

        case .errorOccurred(let message):
            state.errorMessage = message
            state.isLoading = false
            state.isSaving = false

        case .clearError:
            state.errorMessage = nil
        }
    }

    // MARK: - Private Helpers

    private static func mergeAssignments(
        existing: [DayAssignment],
        weekStartDate: Date,
        userGroupID: UUID?
    ) -> [DayAssignment] {
        guard let userGroupID = userGroupID else { return existing }

        let calendar = Calendar.current
        var result: [DayAssignment] = []

        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStartDate) else {
                continue
            }

            if let existingAssignment = existing.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                result.append(existingAssignment)
            } else {
                result.append(DayAssignment(date: date, userGroupID: userGroupID))
            }
        }

        return result
    }
}
