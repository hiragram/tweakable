import SwiftUI

/// A reusable settings section component with optional header and footer.
///
/// Usage:
/// ```swift
/// SettingsSection(header: "settings_group_settings") {
///     SettingsRow(icon: "gear", title: "settings_button")
///     Divider()
///     SettingsRow(icon: "person", title: "settings_member")
/// }
///
/// SettingsSection(
///     header: "settings_weather_locations",
///     footer: "settings_weather_locations_footer"
/// ) {
///     ForEach(locations) { location in
///         locationRow(location)
///     }
/// }
/// ```
struct SettingsSection<Content: View>: View {
    // MARK: - Properties

    var header: LocalizedStringKey? = nil
    var footer: LocalizedStringKey? = nil
    var footerText: String? = nil
    @ViewBuilder let content: () -> Content

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Header
            if let header = header {
                Text(header, bundle: .app)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }

            // Content card
            VStack(spacing: 0) {
                content()
            }
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))

            // Footer
            if let footer = footer {
                Text(footer, bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            } else if let footerText = footerText {
                Text(footerText)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            }
        }
    }
}

// MARK: - Settings Divider

/// A divider styled for use within SettingsSection.
struct SettingsDivider: View {
    private let theme = DesignSystem.default

    var body: some View {
        Divider()
            .background(theme.colors.separator.color)
            .padding(.leading, theme.spacing.md)
    }
}

// MARK: - Previews

#Preview("SettingsSection - WithHeader") {
    SettingsSection(header: "settings_group_settings") {
        SettingsRow(
            icon: "gearshape.2",
            title: "settings_group_settings"
        )
    }
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsSection - WithHeaderAndFooter") {
    SettingsSection(
        header: "settings_weather_locations",
        footer: "settings_weather_locations_footer"
    ) {
        SettingsRow(
            icon: "mappin.circle.fill",
            title: "settings_weather_locations",
            subtitle: "東京都渋谷区"
        )
        SettingsDivider()
        SettingsRow(
            icon: "plus.circle.fill",
            title: "settings_add_location",
            showChevron: false
        )
    }
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsSection - MultipleRows") {
    SettingsSection(header: "settings_group_settings") {
        SettingsRow(
            icon: "person.badge.plus",
            title: "settings_pending_requests",
            badge: 3
        )
        SettingsDivider()
        SettingsRow(
            icon: "person.crop.circle.badge.plus",
            title: "settings_invite_member_button"
        )
        SettingsDivider()
        SettingsRow(
            icon: "calendar",
            title: "settings_weekday_settings_button"
        )
        SettingsDivider()
        SettingsRow(
            icon: "trash",
            title: "settings_delete_group",
            isDestructive: true
        )
    }
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsSection - NoHeader") {
    SettingsSection {
        SettingsRow(
            icon: "person.2",
            title: "settings_view_members"
        )
    }
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}
