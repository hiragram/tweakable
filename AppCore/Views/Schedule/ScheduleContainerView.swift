import SwiftUI

/// StoreとWeeklyScheduleViewを接続するコンテナ
struct ScheduleContainerView: View {
    let store: AppStore
    var onSubmitCompleted: () -> Void = {}

    var body: some View {
        WeeklyScheduleView_Okumuka(
            weekEntries: store.state.schedule.weekEntries,
            currentUser: store.state.schedule.currentUser,
            isLoading: store.state.schedule.isLoading,
            isSaving: store.state.schedule.isSaving,
            isEditable: store.state.schedule.isEditable,
            errorMessage: store.state.schedule.errorMessage,
            enabledWeekdays: store.state.schedule.currentGroup?.enabledWeekdays ?? UserGroup.defaultEnabledWeekdays,
            onDropOffTap: { index in
                let currentStatus = store.state.schedule.weekEntries[index].dropOffStatus
                store.send(.schedule(.updateEntry(index: index, dropOff: currentStatus.next(), pickUp: nil)))
            },
            onPickUpTap: { index in
                let currentStatus = store.state.schedule.weekEntries[index].pickUpStatus
                store.send(.schedule(.updateEntry(index: index, dropOff: nil, pickUp: currentStatus.next())))
            },
            onSubmit: {
                store.send(.schedule(.submitSchedule))
            },
            onClearError: {
                store.send(.schedule(.clearError))
            }
        )
        .onChange(of: store.state.schedule.showSuccessToast) { _, newValue in
            if newValue {
                onSubmitCompleted()
            }
        }
    }
}
