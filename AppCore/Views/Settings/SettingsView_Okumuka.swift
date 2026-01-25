import Prefire
import SwiftUI

/// Settings screen view (parameter-based, no @State)
struct SettingsView_Okumuka<GroupSettingsDestination: View>: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case doneButton
        case myAssignmentsButton
        case groupSettingsButton
        case memberListButton
        case locationButton(id: UUID)
        case addLocationButton
        case invitationUrlTextField
        case joinGroupButton
        case joinWithCodeButton
        case alertOkButton
        case aboutButton

        public var rawIdentifier: String {
            switch self {
            case .doneButton:
                return "settings_button_done"
            case .myAssignmentsButton:
                return "settings_button_myAssignments"
            case .groupSettingsButton:
                return "settings_button_groupSettings"
            case .memberListButton:
                return "settings_button_memberList"
            case .locationButton(let id):
                return "settings_button_location_\(id.uuidString)"
            case .addLocationButton:
                return "settings_button_addLocation"
            case .invitationUrlTextField:
                return "settings_textField_invitationUrl"
            case .joinGroupButton:
                return "settings_button_joinGroup"
            case .joinWithCodeButton:
                return "settings_button_joinWithCode"
            case .alertOkButton:
                return "settings_button_alertOk"
            case .aboutButton:
                return "settings_button_about"
            }
        }
    }

    // MARK: - Parameters

    let weatherLocations: [WeatherLocation]
    let canAddLocation: Bool
    let pendingJoinRequestsCount: Int
    let isGroupOwner: Bool

    // MARK: - Actions

    let onMyAssignmentsTapped: () -> Void
    let onAddLocationTapped: () -> Void
    let onEditLocation: (WeatherLocation) -> Void
    let onDeleteLocation: (WeatherLocation) -> Void
    let onMemberListTapped: () -> Void
    let onJoinWithCodeTapped: () -> Void
    let onAboutTapped: () -> Void
    let onPasteInvitationURL: (URL) -> Void
    let onDismiss: () -> Void

    // MARK: - Navigation Destination

    @ViewBuilder let groupSettingsDestination: () -> GroupSettingsDestination

    // MARK: - Private

    private let theme = DesignSystem.default
    private let maxLocations = 2

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.lg) {
                        // My Assignments Section
                        myAssignmentsSection

                        // Group Settings Navigation (only for group owners)
                        if isGroupOwner {
                            groupSettingsNavigationSection
                        }

                        // Member List Section
                        memberListSection

                        // Join With Code Section (for joining another group)
                        joinWithCodeSection

                        weatherLocationsSection

                        #if DEBUG
                        joinGroupSection
                        #endif

                        aboutSection

                        Spacer()
                            .frame(height: theme.spacing.xl)
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.top, theme.spacing.md)
                }
            }
            .navigationTitle(String(localized: "settings_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common_done", bundle: .app)) {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier(AccessibilityID.doneButton)
                }
            }
        }
    }

    // MARK: - My Assignments Section

    private var myAssignmentsSection: some View {
        SettingsSection {
            SettingsRow(
                icon: "person.crop.rectangle.stack",
                title: "settings_my_assignments",
                accessibilityIdentifier: AccessibilityID.myAssignmentsButton.rawIdentifier,
                action: onMyAssignmentsTapped
            )
        }
    }

    // MARK: - Group Settings Navigation Section

    private var groupSettingsNavigationSection: some View {
        SettingsSection {
            NavigationLink {
                groupSettingsDestination()
            } label: {
                SettingsRow(
                    icon: "gearshape.2",
                    title: "settings_group_settings",
                    badge: pendingJoinRequestsCount > 0 ? pendingJoinRequestsCount : nil,
                    accessibilityIdentifier: AccessibilityID.groupSettingsButton.rawIdentifier,
                    useButton: false
                )
            }
        }
    }

    // MARK: - Member List Section

    private var memberListSection: some View {
        SettingsSection(header: "settings_member_list") {
            SettingsRow(
                icon: "person.2",
                title: "settings_view_members",
                accessibilityIdentifier: AccessibilityID.memberListButton.rawIdentifier,
                action: onMemberListTapped
            )
        }
    }

    // MARK: - Join With Code Section

    private var joinWithCodeSection: some View {
        SettingsSection {
            SettingsRow(
                icon: "rectangle.and.pencil.and.ellipsis",
                title: "settings_join_with_code",
                accessibilityIdentifier: AccessibilityID.joinWithCodeButton.rawIdentifier,
                action: onJoinWithCodeTapped
            )
        }
    }

    // MARK: - Weather Locations Section

    private var weatherLocationsSection: some View {
        SettingsSection(
            header: "settings_weather_locations",
            footerText: String(format: String(localized: "settings_weather_locations_footer", bundle: .app), maxLocations)
        ) {
            if weatherLocations.isEmpty {
                emptyLocationView
            } else {
                ForEach(Array(weatherLocations.enumerated()), id: \.element.id) { index, location in
                    SettingsRow(
                        icon: "mappin.circle.fill",
                        title: LocalizedStringKey(location.label),
                        subtitle: location.placeName,
                        accessibilityIdentifier: AccessibilityID.locationButton(id: location.id).rawIdentifier,
                        action: { onEditLocation(location) }
                    )

                    if index < weatherLocations.count - 1 || canAddLocation {
                        SettingsDivider()
                    }
                }
            }

            if canAddLocation {
                SettingsRow(
                    icon: "plus.circle.fill",
                    title: "settings_add_location",
                    showChevron: false,
                    accessibilityIdentifier: AccessibilityID.addLocationButton.rawIdentifier,
                    action: onAddLocationTapped
                )
            }
        }
    }

    private var emptyLocationView: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "location.slash")
                .font(.system(size: 20))
                .foregroundColor(theme.colors.textTertiary.color)
            Text("settings_no_locations", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textTertiary.color)
            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
    }

    // MARK: - Join Group Section (Dev)

    @State private var invitationURLText: String = ""
    @State private var showInvalidURLAlert: Bool = false

    private var joinGroupSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("settings_join_group", bundle: .app)
                .font(theme.typography.headlineSmall.font)
                .foregroundColor(theme.colors.textSecondary.color)

            VStack(spacing: theme.spacing.sm) {
                TextField(
                    String(localized: "settings_join_group_placeholder", bundle: .app),
                    text: $invitationURLText
                )
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .accessibilityIdentifier(AccessibilityID.invitationUrlTextField)

                Button {
                    if let url = URL(string: invitationURLText.trimmingCharacters(in: .whitespacesAndNewlines)),
                       url.scheme == "https" {
                        onPasteInvitationURL(url)
                        invitationURLText = ""
                    } else {
                        showInvalidURLAlert = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("settings_join_group_button", bundle: .app)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .disabled(invitationURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier(AccessibilityID.joinGroupButton)
            }
            .padding(theme.spacing.md)
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))

            Text("settings_join_group_footer", bundle: .app)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textTertiary.color)
        }
        .alert(
            String(localized: "settings_join_group_invalid_url", bundle: .app),
            isPresented: $showInvalidURLAlert
        ) {
            Button(String(localized: "common_ok", bundle: .app), role: .cancel) {}
                .accessibilityIdentifier(AccessibilityID.alertOkButton)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsSection(header: "settings_about_section") {
            SettingsRow(
                icon: "info.circle",
                title: "settings_about_app",
                accessibilityIdentifier: AccessibilityID.aboutButton.rawIdentifier,
                action: onAboutTapped
            )
        }
    }
}

// MARK: - Preview

#Preview("SettingsView_Okumuka - Empty") {
    SettingsView_Okumuka(
        weatherLocations: [],
        canAddLocation: true,
        pendingJoinRequestsCount: 0,
        isGroupOwner: true,
        onMyAssignmentsTapped: {},
        onAddLocationTapped: {},
        onEditLocation: { _ in },
        onDeleteLocation: { _ in },
        onMemberListTapped: {},
        onJoinWithCodeTapped: {},
        onAboutTapped: {},
        onPasteInvitationURL: { _ in },
        onDismiss: {},
        groupSettingsDestination: { Text("Group Settings") }
    )
}

#Preview("SettingsView_Okumuka - WithLocations") {
    let locations = [
        WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区神南1丁目",
            userGroupID: UUID()
        ),
        WeatherLocation(
            label: "保育園",
            latitude: 35.6812,
            longitude: 139.7671,
            placeName: "東京都新宿区西新宿2丁目",
            userGroupID: UUID()
        )
    ]

    return SettingsView_Okumuka(
        weatherLocations: locations,
        canAddLocation: false,
        pendingJoinRequestsCount: 3,
        isGroupOwner: true,
        onMyAssignmentsTapped: {},
        onAddLocationTapped: {},
        onEditLocation: { _ in },
        onDeleteLocation: { _ in },
        onMemberListTapped: {},
        onJoinWithCodeTapped: {},
        onAboutTapped: {},
        onPasteInvitationURL: { _ in },
        onDismiss: {},
        groupSettingsDestination: { Text("Group Settings") }
    )
}

#Preview("SettingsView_Okumuka - OneLocation") {
    let locations = [
        WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区神南1丁目",
            userGroupID: UUID()
        )
    ]

    return SettingsView_Okumuka(
        weatherLocations: locations,
        canAddLocation: true,
        pendingJoinRequestsCount: 1,
        isGroupOwner: true,
        onMyAssignmentsTapped: {},
        onAddLocationTapped: {},
        onEditLocation: { _ in },
        onDeleteLocation: { _ in },
        onMemberListTapped: {},
        onJoinWithCodeTapped: {},
        onAboutTapped: {},
        onPasteInvitationURL: { _ in },
        onDismiss: {},
        groupSettingsDestination: { Text("Group Settings") }
    )
}

#Preview("SettingsView_Okumuka - NonOwner") {
    let locations = [
        WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区神南1丁目",
            userGroupID: UUID()
        )
    ]

    return SettingsView_Okumuka(
        weatherLocations: locations,
        canAddLocation: true,
        pendingJoinRequestsCount: 0,
        isGroupOwner: false,
        onMyAssignmentsTapped: {},
        onAddLocationTapped: {},
        onEditLocation: { _ in },
        onDeleteLocation: { _ in },
        onMemberListTapped: {},
        onJoinWithCodeTapped: {},
        onAboutTapped: {},
        onPasteInvitationURL: { _ in },
        onDismiss: {},
        groupSettingsDestination: { Text("Group Settings") }
    )
}
