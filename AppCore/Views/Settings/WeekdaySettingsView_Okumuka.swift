import Prefire
import SwiftUI

/// 曜日設定画面（パラメータ形式）
struct WeekdaySettingsView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case doneButton
        case weekdayToggle(identifier: String)

        public var rawIdentifier: String {
            switch self {
            case .doneButton:
                return "weekdaySettings_button_done"
            case .weekdayToggle(let identifier):
                return "weekdaySettings_toggle_\(identifier)"
            }
        }
    }

    // MARK: - Parameters

    let enabledWeekdays: [Int: Bool]

    // MARK: - Actions

    let onEnabledWeekdayChanged: (Int, Bool) -> Void
    let onDismiss: () -> Void

    // MARK: - Private

    private let theme = DesignSystem.default

    /// 曜日設定（日本式順序: 月火水木金土日）
    /// Foundation.Calendarの曜日番号: 1=日曜, 2=月曜, ..., 7=土曜
    private static let weekdayOrder: [(weekday: Int, localizationKey: String, identifier: String)] = [
        (2, "weekday_monday", "monday"),
        (3, "weekday_tuesday", "tuesday"),
        (4, "weekday_wednesday", "wednesday"),
        (5, "weekday_thursday", "thursday"),
        (6, "weekday_friday", "friday"),
        (7, "weekday_saturday", "saturday"),
        (1, "weekday_sunday", "sunday")
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.lg) {
                        weekdayTogglesSection

                        Spacer()
                            .frame(height: theme.spacing.xl)
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.top, theme.spacing.md)
                }
            }
            .navigationTitle(String(localized: "settings_weekday_settings", bundle: .app))
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

    // MARK: - Weekday Toggles Section

    private var weekdayTogglesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Content card
            VStack(spacing: 0) {
                ForEach(Array(Self.weekdayOrder.enumerated()), id: \.element.weekday) { index, item in
                    weekdayToggleRow(
                        weekday: item.weekday,
                        localizationKey: item.localizationKey,
                        identifier: item.identifier
                    )

                    if index < Self.weekdayOrder.count - 1 {
                        Divider()
                            .background(theme.colors.separator.color)
                            .padding(.leading, theme.spacing.md)
                    }
                }
            }
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))

            // Section footer
            Text("settings_weekday_settings_footer", bundle: .app)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textTertiary.color)
        }
    }

    private func weekdayToggleRow(weekday: Int, localizationKey: String, identifier: String) -> some View {
        HStack {
            Text(String(localized: String.LocalizationValue(localizationKey), bundle: .app))
                .font(theme.typography.bodyLarge.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Spacer()

            Toggle("", isOn: Binding(
                get: { enabledWeekdays[weekday] ?? false },
                set: { onEnabledWeekdayChanged(weekday, $0) }
            ))
            .tint(theme.colors.primaryBrand.color)
            .labelsHidden()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .accessibilityIdentifier(AccessibilityID.weekdayToggle(identifier: identifier))
    }
}

// MARK: - Preview

#Preview("WeekdaySettingsView_Okumuka") {
    WeekdaySettingsView_Okumuka(
        enabledWeekdays: UserGroup.defaultEnabledWeekdays,
        onEnabledWeekdayChanged: { _, _ in },
        onDismiss: {}
    )
}

#Preview("WeekdaySettingsView_Okumuka - AllEnabled") {
    WeekdaySettingsView_Okumuka(
        enabledWeekdays: [1: true, 2: true, 3: true, 4: true, 5: true, 6: true, 7: true],
        onEnabledWeekdayChanged: { _, _ in },
        onDismiss: {}
    )
}
