import SwiftUI

/// A reusable settings row component for navigation-style list items.
///
/// Usage:
/// ```swift
/// // Basic navigation row with button
/// SettingsRow(
///     icon: "gear",
///     title: "settings_button",
///     action: { onSettingsTapped() }
/// )
///
/// // With badge
/// SettingsRow(
///     icon: "person.badge.plus",
///     title: "settings_pending_requests",
///     badge: pendingCount,
///     action: { onJoinRequestsTapped() }
/// )
///
/// // Destructive style
/// SettingsRow(
///     icon: "trash",
///     title: "settings_delete",
///     isDestructive: true,
///     action: { onDeleteTapped() }
/// )
///
/// // For use inside NavigationLink (no button wrapper)
/// NavigationLink {
///     DestinationView()
/// } label: {
///     SettingsRow(
///         icon: "gearshape.2",
///         title: "settings_group_settings",
///         useButton: false
///     )
/// }
/// ```
///
/// - Warning: When using inside NavigationLink, you MUST set `useButton: false`
///   to avoid button nesting issues. Nested buttons prevent tap gestures from
///   working correctly in SwiftUI.
struct SettingsRow: View {
    // MARK: - Required Properties

    let icon: String
    let title: LocalizedStringKey

    // MARK: - Optional Properties

    var subtitle: String? = nil
    var iconColor: Color? = nil
    var badge: Int? = nil
    var isDestructive: Bool = false
    var showChevron: Bool = true
    var isLoading: Bool = false
    var accessibilityIdentifier: String? = nil
    var action: (() -> Void)? = nil
    var useButton: Bool = true

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Computed Properties

    private var effectiveIconColor: Color {
        if isDestructive {
            return .red
        }
        return iconColor ?? theme.colors.primaryBrand.color
    }

    private var textColor: Color {
        if isDestructive {
            return .red
        }
        return theme.colors.textPrimary.color
    }

    // MARK: - Body

    var body: some View {
        if useButton {
            Button {
                action?()
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .modifier(AccessibilityIdentifierModifier(identifier: accessibilityIdentifier))
        } else {
            // NavigationLink内で使用される場合、アクセシビリティ上もボタンとして認識させる
            rowContent
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isButton)
                .modifier(AccessibilityIdentifierModifier(identifier: accessibilityIdentifier))
        }
    }

    // MARK: - Row Content

    private var rowContent: some View {
        HStack(spacing: theme.spacing.sm) {
            // Icon
            iconView

            // Text content
            textContent

            Spacer()

            // Trailing content
            trailingContent
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    @ViewBuilder
    private var iconView: some View {
        if isLoading {
            ProgressView()
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(effectiveIconColor)
        }
    }

    @ViewBuilder
    private var textContent: some View {
        if let subtitle = subtitle {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title, bundle: .app)
                    .font(theme.typography.bodyLarge.font)
                    .foregroundColor(textColor)

                Text(subtitle)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .lineLimit(1)
            }
        } else {
            Text(title, bundle: .app)
                .font(theme.typography.bodyLarge.font)
                .foregroundColor(textColor)
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        HStack(spacing: theme.spacing.xs) {
            // Badge
            if let badge = badge, badge > 0 {
                Text("\(badge)")
                    .font(theme.typography.captionLarge.font)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxs)
                    .background(theme.colors.primaryBrand.color)
                    .clipShape(Capsule())
            }

            // Chevron
            if showChevron && !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.colors.textTertiary.color)
            }
        }
    }
}

// MARK: - Accessibility Identifier Modifier

private struct AccessibilityIdentifierModifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier = identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

// MARK: - Previews

#Preview("SettingsRow - Navigation") {
    VStack(spacing: 0) {
        SettingsRow(
            icon: "gearshape.2",
            title: "settings_group_settings"
        )
        Divider()
        SettingsRow(
            icon: "person.crop.circle.badge.plus",
            title: "settings_invite_member_button"
        )
    }
    .background(DesignSystem.default.colors.backgroundSecondary.color)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsRow - WithBadge") {
    SettingsRow(
        icon: "person.badge.plus",
        title: "settings_pending_requests",
        badge: 3
    )
    .background(DesignSystem.default.colors.backgroundSecondary.color)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsRow - Destructive") {
    SettingsRow(
        icon: "trash",
        title: "settings_delete_group",
        isDestructive: true
    )
    .background(DesignSystem.default.colors.backgroundSecondary.color)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsRow - WithSubtitle") {
    SettingsRow(
        icon: "mappin.circle.fill",
        title: "settings_weather_locations",
        subtitle: "東京都渋谷区神南1丁目"
    )
    .background(DesignSystem.default.colors.backgroundSecondary.color)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsRow - Loading") {
    SettingsRow(
        icon: "trash",
        title: "settings_delete_group",
        isDestructive: true,
        isLoading: true
    )
    .background(DesignSystem.default.colors.backgroundSecondary.color)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(DesignSystem.default.colors.backgroundPrimary.color)
}

#Preview("SettingsRow - InNavigationLink") {
    NavigationStack {
        List {
            NavigationLink {
                Text("Destination View")
                    .navigationTitle("Group Settings")
            } label: {
                SettingsRow(
                    icon: "gearshape.2",
                    title: "settings_group_settings",
                    useButton: false
                )
            }

            NavigationLink {
                Text("Another Destination")
                    .navigationTitle("Weather Locations")
            } label: {
                SettingsRow(
                    icon: "mappin.circle.fill",
                    title: "settings_weather_locations",
                    badge: 3,
                    useButton: false
                )
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }
}
