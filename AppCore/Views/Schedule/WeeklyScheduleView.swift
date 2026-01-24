import Prefire
import SwiftUI

/// 週間スケジュール入力画面（パラメータ形式）
struct WeeklyScheduleView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case errorOkButton
        case submitButton
        case dropOffButton(dayIndex: Int)
        case pickUpButton(dayIndex: Int)

        public var rawIdentifier: String {
            switch self {
            case .errorOkButton:
                return "weeklySchedule_button_errorOk"
            case .submitButton:
                return "weeklySchedule_button_submit"
            case .dropOffButton(let dayIndex):
                return "weeklySchedule_button_dropOff_day\(dayIndex)"
            case .pickUpButton(let dayIndex):
                return "weeklySchedule_button_pickUp_day\(dayIndex)"
            }
        }
    }

    // MARK: - Parameters

    let weekEntries: [DayScheduleEntry]
    let currentUser: User?
    let isLoading: Bool
    let isSaving: Bool
    let isEditable: Bool
    let errorMessage: String?
    /// 有効な曜日の設定（曜日番号 → 有効/無効）
    let enabledWeekdays: [Int: Bool]

    // MARK: - Actions

    let onDropOffTap: (Int) -> Void
    let onPickUpTap: (Int) -> Void
    let onSubmit: () -> Void
    let onClearError: () -> Void

    private let theme = DesignSystem.default

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    scheduleContent
                    submitButtonArea
                }
            }
        }
        .alert(String(localized: "common_error", bundle: .app), isPresented: .constant(errorMessage != nil)) {
            Button(String(localized: "common_ok", bundle: .app)) {
                onClearError()
            }
            .accessibilityIdentifier(AccessibilityID.errorOkButton)
        } message: {
            Text(errorMessage ?? "")
        }
        .overlay(alignment: .top) {
            if !isEditable {
                NetworkStatusBanner(theme: theme)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: theme.spacing.xs) {
            Text("schedule_title", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.textPrimary.color)

            if let userName = currentUser?.displayName {
                Text(String(format: String(localized: "schedule_user_prompt", bundle: .app), userName))
                    .font(theme.typography.bodySmall.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }

            // iCloud sync indicator
            HStack(spacing: theme.spacing.xxs) {
                Image(systemName: "icloud.fill")
                    .font(.system(size: 12))
                Text("schedule_icloud_sync", bundle: .app)
                    .font(theme.typography.captionSmall.font)
            }
            .foregroundColor(theme.colors.textTertiary.color)
            .padding(.top, theme.spacing.xxs)
        }
        .padding(.vertical, theme.spacing.lg)
        .padding(.horizontal, theme.spacing.md)
    }

    // MARK: - Schedule Content

    private var scheduleContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                columnHeader

                ForEach(Array(weekEntries.enumerated()), id: \.element.id) { index, entry in
                    let weekday = Calendar.current.component(.weekday, from: entry.date)
                    let isWeekdayEnabled = enabledWeekdays[weekday] ?? true

                    DayScheduleRow(
                        entry: entry,
                        index: index,
                        theme: theme,
                        isEditable: isEditable && isWeekdayEnabled,
                        isWeekdayDisabled: !isWeekdayEnabled,
                        onDropOffTap: {
                            onDropOffTap(index)
                        },
                        onPickUpTap: {
                            onPickUpTap(index)
                        }
                    )

                    if index < weekEntries.count - 1 {
                        Divider()
                            .background(theme.colors.separator.color)
                            .padding(.leading, 60)
                    }
                }
            }
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.lg))
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.sm)
            .padding(.bottom, theme.spacing.xxl)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Column Header

    private var columnHeader: some View {
        HStack(spacing: theme.spacing.sm) {
            Spacer()

            HStack(spacing: theme.spacing.sm) {
                Text("common_drop_off", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .frame(width: 52)

                Text("common_pick_up", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .frame(width: 52)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.sm)
        .padding(.bottom, theme.spacing.xs)
    }

    // MARK: - Submit Button

    private var submitButtonArea: some View {
        VStack(spacing: theme.spacing.xs) {
            Button {
                onSubmit()
            } label: {
                if isSaving {
                    HStack(spacing: theme.spacing.xs) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("schedule_saving", bundle: .app)
                    }
                } else {
                    Text("schedule_submit", bundle: .app)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .disabled(!isEditable || isSaving)
            .accessibilityIdentifier(AccessibilityID.submitButton)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
        .background(
            theme.colors.backgroundPrimary.color
                .shadow(color: theme.colors.textPrimary.color.opacity(0.06), radius: 8, x: 0, y: -4)
        )
    }
}

// MARK: - Day Schedule Row

struct DayScheduleRow: View {
    let entry: DayScheduleEntry
    let index: Int
    let theme: DesignSystem
    var isEditable: Bool = true
    /// 曜日設定で無効になっている曜日かどうか
    var isWeekdayDisabled: Bool = false
    let onDropOffTap: () -> Void
    let onPickUpTap: () -> Void

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            // Date label
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xxs) {
                Text(entry.monthDay)
                    .font(theme.typography.headlineMedium.font)
                    .foregroundColor(isWeekdayDisabled ? theme.colors.textTertiary.color : theme.colors.textPrimary.color)

                Text(entry.dayOfWeek)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(isWeekdayDisabled ? theme.colors.textTertiary.color : theme.colors.textSecondary.color)
            }

            Spacer()

            // Drop off & Pick up buttons
            HStack(spacing: theme.spacing.sm) {
                ScheduleStatusButton(
                    status: entry.dropOffStatus,
                    theme: theme,
                    isEnabled: isEditable,
                    onTap: onDropOffTap
                )
                .accessibilityIdentifier(WeeklyScheduleView.AccessibilityID.dropOffButton(dayIndex: index))

                ScheduleStatusButton(
                    status: entry.pickUpStatus,
                    theme: theme,
                    isEnabled: isEditable,
                    onTap: onPickUpTap
                )
                .accessibilityIdentifier(WeeklyScheduleView.AccessibilityID.pickUpButton(dayIndex: index))
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .opacity(isWeekdayDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Schedule Status Button

struct ScheduleStatusButton: View {
    let status: ScheduleStatus
    let theme: DesignSystem
    var isEnabled: Bool = true
    let onTap: () -> Void

    private var backgroundColor: Color {
        switch status {
        case .notSet:
            return theme.colors.backgroundTertiary.color
        case .ok:
            return theme.colors.secondaryBrand.color.opacity(0.18)
        case .ng:
            return theme.colors.error.color.opacity(0.15)
        }
    }

    private var accentColor: Color {
        let baseColor: Color = {
            switch status {
            case .notSet:
                return theme.colors.textTertiary.color.opacity(0.5)
            case .ok:
                return theme.colors.secondaryBrand.color
            case .ng:
                return theme.colors.error.color
            }
        }()
        return isEnabled ? baseColor : baseColor.opacity(0.5)
    }

    private var iconName: String {
        switch status {
        case .notSet: return "circle.dashed"
        case .ok: return "checkmark.circle.fill"
        case .ng: return "xmark.circle.fill"
        }
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: iconName)
                .id(iconName)
                .transition(.opacity.animation(.easeOut(duration: 0.1)))
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(accentColor)
                .frame(width: 52, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(ScheduleButtonStyle())
        .disabled(!isEnabled)
    }
}

// MARK: - Schedule Button Style

struct ScheduleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// MARK: - Preview

#Preview("WeeklyScheduleView") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today
    let userID = UUID()
    let groupID = UUID()

    let weekEntries = (0..<7).map { dayOffset -> DayScheduleEntry in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return DayScheduleEntry(
            date: date,
            userID: userID,
            userGroupID: groupID,
            dropOffStatus: dayOffset % 3 == 0 ? .ok : (dayOffset % 3 == 1 ? .ng : .notSet),
            pickUpStatus: dayOffset % 2 == 0 ? .ok : .notSet
        )
    }

    let currentUser = User(iCloudUserID: "test-user-id", displayName: "Papa")

    return WeeklyScheduleView(
        weekEntries: weekEntries,
        currentUser: currentUser,
        isLoading: false,
        isSaving: false,
        isEditable: true,
        errorMessage: nil,
        enabledWeekdays: UserGroup.defaultEnabledWeekdays,
        onDropOffTap: { _ in },
        onPickUpTap: { _ in },
        onSubmit: {},
        onClearError: {}
    )
    .prefireEnabled()
}

#Preview("WeeklyScheduleView - Loading") {
    WeeklyScheduleView(
        weekEntries: [],
        currentUser: nil,
        isLoading: true,
        isSaving: false,
        isEditable: true,
        errorMessage: nil,
        enabledWeekdays: UserGroup.defaultEnabledWeekdays,
        onDropOffTap: { _ in },
        onPickUpTap: { _ in },
        onSubmit: {},
        onClearError: {}
    )
    .prefireEnabled()
}

#Preview("WeeklyScheduleView - Saving") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today
    let userID = UUID()
    let groupID = UUID()

    let weekEntries = (0..<7).map { dayOffset -> DayScheduleEntry in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return DayScheduleEntry(
            date: date,
            userID: userID,
            userGroupID: groupID,
            dropOffStatus: .ok,
            pickUpStatus: .ok
        )
    }

    let currentUser = User(iCloudUserID: "test-user-id", displayName: "Mama")

    return WeeklyScheduleView(
        weekEntries: weekEntries,
        currentUser: currentUser,
        isLoading: false,
        isSaving: true,
        isEditable: true,
        errorMessage: nil,
        enabledWeekdays: UserGroup.defaultEnabledWeekdays,
        onDropOffTap: { _ in },
        onPickUpTap: { _ in },
        onSubmit: {},
        onClearError: {}
    )
    .prefireEnabled()
}

#Preview("WeeklyScheduleView - Offline") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today
    let userID = UUID()
    let groupID = UUID()

    let weekEntries = (0..<7).map { dayOffset -> DayScheduleEntry in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return DayScheduleEntry(
            date: date,
            userID: userID,
            userGroupID: groupID,
            dropOffStatus: .notSet,
            pickUpStatus: .notSet
        )
    }

    let currentUser = User(iCloudUserID: "test-user-id", displayName: "Papa")

    return WeeklyScheduleView(
        weekEntries: weekEntries,
        currentUser: currentUser,
        isLoading: false,
        isSaving: false,
        isEditable: false,
        errorMessage: nil,
        enabledWeekdays: UserGroup.defaultEnabledWeekdays,
        onDropOffTap: { _ in },
        onPickUpTap: { _ in },
        onSubmit: {},
        onClearError: {}
    )
    .prefireEnabled()
}

