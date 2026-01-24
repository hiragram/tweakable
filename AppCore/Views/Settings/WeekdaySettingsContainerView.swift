import SwiftUI

/// Container view that connects AppStore to WeekdaySettingsView
struct WeekdaySettingsContainerView: View {
    let store: AppStore
    let onDismiss: () -> Void

    var body: some View {
        WeekdaySettingsView(
            enabledWeekdays: store.state.schedule.currentGroup?.enabledWeekdays ?? UserGroup.defaultEnabledWeekdays,
            onEnabledWeekdayChanged: { weekday, enabled in
                store.send(.schedule(.updateEnabledWeekday(weekday: weekday, enabled: enabled)))
            },
            onDismiss: onDismiss
        )
    }
}
