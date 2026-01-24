import Foundation

/// 自分の担当一覧画面のReducer（純粋関数）
public enum MyAssignmentsReducer {
    public static func reduce(state: inout MyAssignmentsState, action: MyAssignmentsAction) {
        switch action {
        case .loadMyAssignments:
            state.isLoading = true
            state.errorMessage = nil

        case .myAssignmentsLoaded(let assignments):
            state.isLoading = false
            state.myAssignments = assignments

        case .setLoading(let isLoading):
            state.isLoading = isLoading

        case .errorOccurred(let message):
            state.isLoading = false
            state.errorMessage = message

        case .clearError:
            state.errorMessage = nil
        }
    }

    // MARK: - ヘルパー関数（純粋関数、テスト対象）

    /// DayAssignmentの配列から、指定したユーザーIDの担当だけを抽出する
    /// - Parameters:
    ///   - assignments: 全グループのDayAssignment（グループ情報付き）
    ///   - userID: 現在のユーザーID
    ///   - today: 今日の日付（テスト用にパラメータ化）
    /// - Returns: 自分の担当アイテムの配列（日付昇順）
    public static func filterMyAssignments(
        assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)],
        userID: UUID,
        today: Date
    ) -> [MyAssignmentItem] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)

        var result: [MyAssignmentItem] = []

        for item in assignments {
            let assignment = item.assignment

            // 今日以降のみ
            guard assignment.date >= startOfToday else { continue }

            // 送り担当が自分の場合
            if assignment.assignedDropOffUserID == userID {
                result.append(MyAssignmentItem(
                    date: assignment.date,
                    groupID: item.groupID,
                    groupName: item.groupName,
                    assignmentType: .dropOff
                ))
            }

            // 迎え担当が自分の場合
            if assignment.assignedPickUpUserID == userID {
                result.append(MyAssignmentItem(
                    date: assignment.date,
                    groupID: item.groupID,
                    groupName: item.groupName,
                    assignmentType: .pickUp
                ))
            }
        }

        // 日付昇順でソート
        return result.sorted { $0.date < $1.date }
    }

    /// 担当アイテムを日付でグルーピングする
    /// - Parameter assignments: 自分の担当アイテム
    /// - Returns: 日付ごとにグルーピングされた辞書
    public static func groupByDate(_ assignments: [MyAssignmentItem]) -> [Date: [MyAssignmentItem]] {
        Dictionary(grouping: assignments) { item in
            Calendar.current.startOfDay(for: item.date)
        }
    }
}
