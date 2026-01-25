import SwiftUI

/// Group settings detail view (parameter-based, no @State)
struct GroupSettingsView: View {
    // MARK: - Parameters

    let pendingJoinRequestsCount: Int
    let isDeletingGroup: Bool

    // MARK: - Actions

    let onJoinRequestsTapped: () -> Void
    let onInviteMemberTapped: () -> Void
    let onWeekdaySettingsTapped: () -> Void
    let onDeleteGroupTapped: () -> Void

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    groupManagementSection

                    dangerZoneSection

                    Spacer()
                        .frame(height: theme.spacing.xl)
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.top, theme.spacing.md)
            }
        }
        .navigationTitle(String(localized: "groupSettings_title", bundle: .app))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Group Management Section

    private var groupManagementSection: some View {
        SettingsSection(
            header: "groupSettings_management_header",
            footer: "settings_weekday_settings_footer"
        ) {
            // Join Requests (only shown when there are pending requests)
            if pendingJoinRequestsCount > 0 {
                SettingsRow(
                    icon: "person.badge.plus",
                    title: "settings_pending_requests",
                    badge: pendingJoinRequestsCount,
                    accessibilityIdentifier: "groupSettings_button_joinRequests",
                    action: onJoinRequestsTapped
                )

                SettingsDivider()
            }

            // Invite Member
            SettingsRow(
                icon: "person.crop.circle.badge.plus",
                title: "settings_invite_member_button",
                accessibilityIdentifier: "groupSettings_button_inviteMember",
                action: onInviteMemberTapped
            )

            SettingsDivider()

            // Weekday Settings
            SettingsRow(
                icon: "calendar",
                title: "settings_weekday_settings_button",
                accessibilityIdentifier: "groupSettings_button_weekdaySettings",
                action: onWeekdaySettingsTapped
            )
        }
    }

    // MARK: - Danger Zone Section

    private var dangerZoneSection: some View {
        SettingsSection {
            SettingsRow(
                icon: "trash",
                title: "settings_delete_group",
                isDestructive: true,
                isLoading: isDeletingGroup,
                accessibilityIdentifier: "groupSettings_button_deleteGroup",
                action: isDeletingGroup ? nil : onDeleteGroupTapped
            )
        }
    }
}

// MARK: - Preview

#Preview("GroupSettingsView - Default") {
    NavigationStack {
        GroupSettingsView(
            pendingJoinRequestsCount: 0,
            isDeletingGroup: false,
            onJoinRequestsTapped: {},
            onInviteMemberTapped: {},
            onWeekdaySettingsTapped: {},
            onDeleteGroupTapped: {}
        )
    }
}

#Preview("GroupSettingsView - WithPendingRequests") {
    NavigationStack {
        GroupSettingsView(
            pendingJoinRequestsCount: 3,
            isDeletingGroup: false,
            onJoinRequestsTapped: {},
            onInviteMemberTapped: {},
            onWeekdaySettingsTapped: {},
            onDeleteGroupTapped: {}
        )
    }
}

#Preview("GroupSettingsView - Deleting") {
    NavigationStack {
        GroupSettingsView(
            pendingJoinRequestsCount: 0,
            isDeletingGroup: true,
            onJoinRequestsTapped: {},
            onInviteMemberTapped: {},
            onWeekdaySettingsTapped: {},
            onDeleteGroupTapped: {}
        )
    }
}
