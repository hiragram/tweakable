import SwiftUI

/// 自分の担当一覧画面のコンテナビュー
struct MyAssignmentsContainerView: View {
    let store: AppStore
    let onDismiss: () -> Void

    var body: some View {
        let assignmentsByDate = MyAssignmentsReducer.groupByDate(
            store.state.myAssignments.myAssignments
        )
        let sortedDates = assignmentsByDate.keys.sorted()

        MyAssignmentsView_Okumuka(
            assignmentsByDate: assignmentsByDate,
            sortedDates: sortedDates,
            isLoading: store.state.myAssignments.isLoading,
            errorMessage: store.state.myAssignments.errorMessage,
            onRefresh: {
                store.send(.myAssignments(.loadMyAssignments))
            },
            onDismiss: onDismiss
        )
        .onAppear {
            store.send(.myAssignments(.loadMyAssignments))
        }
    }
}
