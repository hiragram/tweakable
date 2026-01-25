import SwiftUI

/// Container view that connects AppStore to GroupSettingsView
struct GroupSettingsContainerView: View {
    let store: AppStore

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Local State

    @State private var showsJoinRequests = false
    @State private var showsInviteMember = false
    @State private var showsWeekdaySettings = false
    @State private var showsDeleteConfirmation = false

    // MARK: - Body

    var body: some View {
        GroupSettingsView_Okumuka(
            pendingJoinRequestsCount: store.state.sharing.pendingJoinRequests.count,
            isDeletingGroup: store.state.schedule.isDeletingGroup,
            onJoinRequestsTapped: {
                showsJoinRequests = true
            },
            onInviteMemberTapped: {
                showsInviteMember = true
            },
            onWeekdaySettingsTapped: {
                showsWeekdaySettings = true
            },
            onDeleteGroupTapped: {
                showsDeleteConfirmation = true
            }
        )
        .sheet(isPresented: $showsJoinRequests) {
            JoinRequestListContainerView(
                store: store,
                onDismiss: {
                    showsJoinRequests = false
                }
            )
        }
        .sheet(isPresented: $showsInviteMember) {
            InviteCodeContainerView(
                store: store,
                groupName: store.state.schedule.currentGroup?.name ?? "",
                onDismiss: {
                    showsInviteMember = false
                }
            )
        }
        .sheet(isPresented: $showsWeekdaySettings) {
            WeekdaySettingsContainerView(
                store: store,
                onDismiss: {
                    showsWeekdaySettings = false
                }
            )
        }
        .confirmationDialog(
            String(localized: "settings_delete_group_confirm_title", bundle: .app),
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "settings_delete_group", bundle: .app), role: .destructive) {
                if let groupID = store.state.schedule.currentGroup?.id {
                    store.send(.schedule(.deleteGroup(groupID)))
                }
            }
            Button(String(localized: "common_cancel", bundle: .app), role: .cancel) {}
        } message: {
            Text("settings_delete_group_confirm_message", bundle: .app)
        }
        .onAppear {
            // Load pending join requests when this screen appears
            store.send(.sharing(.loadPendingJoinRequests))
        }
        .onChange(of: store.state.schedule.currentGroup?.id) { oldID, newID in
            // グループが削除または切り替わった場合、NavigationStackから戻る
            // oldID != nil: 初期表示時（nil→IDへの変化）は無視
            // newID != oldID: グループが変わった（削除または切り替え）
            if oldID != nil && newID != oldID {
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview("GroupSettingsContainerView") {
    Text("Preview requires AppStore setup")
}
