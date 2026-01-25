import Foundation
import Prefire
import SwiftUI
import WeatherKit

/// Home screen view (parameter-based, no @State)
public struct HomeView_Okumuka: View {

    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case enterScheduleButton
        case settingsButton
        case createGroupMenu
        case groupSelector
        case addWeatherLocationButton
        case decideAssigneeButton
        case toggleWarningsButton
        case groupMenu(groupID: UUID)

        public var rawIdentifier: String {
            switch self {
            case .enterScheduleButton:
                return "home_button_enterSchedule"
            case .settingsButton:
                return "home_button_settings"
            case .createGroupMenu:
                return "home_menu_createGroup"
            case .groupSelector:
                return "home_menu_groupSelector"
            case .addWeatherLocationButton:
                return "home_button_addWeatherLocation"
            case .decideAssigneeButton:
                return "home_button_decideAssignee"
            case .toggleWarningsButton:
                return "home_button_toggleWarnings"
            case .groupMenu(let groupID):
                return "home_menu_group_\(groupID.uuidString)"
            }
        }
    }
    // MARK: - Parameters

    let groupName: String
    let groups: [UserGroup]
    let todayDropOff: HomeAssignmentStatus
    let todayPickUp: HomeAssignmentStatus
    let weatherLocations: [WeatherLocation]
    let weathers: [HomeWeatherData]
    let weatherTargetDate: Date?
    let weekSchedule: [HomeDaySchedule]
    let weeklyWeatherByLocation: [(location: WeatherLocation, icons: [Date: String])]
    let warnings: [HomeWarning]
    let currentUserName: String
    let isLoadingWeather: Bool
    let isOwner: Bool

    // MARK: - Actions

    let onScheduleInputTapped: () -> Void
    let onSettingsTapped: () -> Void
    let onDecideAssigneeTapped: () -> Void
    let onGroupSelected: (UUID) -> Void
    let onCreateGroupTapped: () -> Void
    let onRefresh: () async -> Void

    // MARK: - Private

    private let theme = DesignSystem.default
    private let maxVisibleWarnings = 3

    // MARK: - Local State

    @State private var isWarningsExpanded = false

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.md) {
                    todaySection
                    weatherSection
                    weeklySection
                    if isOwner {
                        ownerSection
                    }
                    warningsSection
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.lg)
                // ボタン分の余白を確保
                .padding(.bottom, 60)
                .frame(maxWidth: .infinity)
            }
            .refreshable {
                await onRefresh()
            }
            .overlay(alignment: .bottom) {
                // フローティングボタン
                Button {
                    onScheduleInputTapped()
                } label: {
                    Text("home_enter_schedule", bundle: .app)
                }
                .buttonStyle(PrimaryButtonStyle(theme: theme))
                .shadow(theme.shadow.floatingUp)
                .padding(.horizontal, theme.spacing.md)
                .padding(.bottom, theme.spacing.lg)
                .accessibilityIdentifier(AccessibilityID.enterScheduleButton)
            }
            .background(theme.colors.backgroundPrimary.color.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    groupSelectorView
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSettingsTapped()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary.color)
                    }
                    .accessibilityIdentifier(AccessibilityID.settingsButton)
                }
            }
        }
    }

    // MARK: - Group Selector

    private var groupSelectorView: some View {
        Menu {
            // 既存グループ一覧
            ForEach(groups) { group in
                Button {
                    onGroupSelected(group.id)
                } label: {
                    HStack {
                        Text(group.name)
                        if group.name == groupName {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .accessibilityIdentifier(AccessibilityID.groupMenu(groupID: group.id))
            }

            Divider()

            // 新しいグループを作成
            Button {
                onCreateGroupTapped()
            } label: {
                Label(String(localized: "home_create_new_group", bundle: .app), systemImage: "plus")
            }
            .accessibilityIdentifier(AccessibilityID.createGroupMenu)
        } label: {
            HStack(spacing: 4) {
                Text(groupName)
                    .font(.headline)
                    .foregroundColor(theme.colors.textPrimary.color)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(theme.colors.textSecondary.color)
            }
        }
        .accessibilityIdentifier(AccessibilityID.groupSelector)
    }

    // MARK: - Today's Schedule Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader(title: String(localized: "home_today_schedule", bundle: .app), icon: "calendar.badge.clock")

            HStack(spacing: theme.spacing.sm) {
                assignmentCard(title: String(localized: "common_drop_off", bundle: .app), status: todayDropOff)
                assignmentCard(title: String(localized: "common_pick_up", bundle: .app), status: todayPickUp)
            }
        }
    }

    private func assignmentCard(title: String, status: HomeAssignmentStatus) -> some View {
        let (backgroundColor, textColor, personText, icon) = assignmentCardStyle(for: status)

        return VStack(spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textSecondary.color)

            HStack(spacing: theme.spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))

                Text(personText)
                    .font(theme.typography.headlineLarge.font)
            }
            .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(backgroundColor)
        )
    }

    private func assignmentCardStyle(for status: HomeAssignmentStatus) -> (Color, Color, String, String) {
        switch status {
        case .confirmed(let name):
            return (
                theme.colors.backgroundSecondary.color,
                theme.colors.textPrimary.color,
                name,
                "person.fill"
            )
        case .unconfirmed:
            return (
                theme.colors.warning.color.opacity(0.15),
                theme.colors.warning.color,
                String(localized: "home_status_unconfirmed", bundle: .app),
                "questionmark.circle.fill"
            )
        case .noAssignee:
            return (
                theme.colors.error.color.opacity(0.15),
                theme.colors.error.color,
                String(localized: "home_status_no_assignee", bundle: .app),
                "exclamationmark.triangle.fill"
            )
        }
    }

    // MARK: - Weather Section

    private var weatherSectionTitle: String {
        guard let targetDate = weatherTargetDate else {
            return String(localized: "home_weather_forecast", bundle: .app)
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(targetDate) {
            return String(localized: "home_today_weather", bundle: .app)
        } else {
            return String(localized: "home_tomorrow_weather", bundle: .app)
        }
    }

    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader(title: weatherSectionTitle, icon: "cloud.sun")

            if isLoadingWeather {
                weatherLoadingView
            } else if weatherLocations.isEmpty {
                // 地点が未登録
                weatherEmptyView
            } else if weathers.isEmpty {
                // 地点はあるが天気取得失敗
                weatherErrorView
            } else {
                weatherCardsView
            }
        }
    }

    private var weatherCardsView: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(weathers) { weather in
                weatherCard(weather)
            }
        }
    }

    private func weatherCard(_ weather: HomeWeatherData) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Location label
            Text(weather.locationLabel)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textSecondary.color)

            // アイコン + 天気説明（横並び）
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: weather.iconName)
                    .font(.system(size: 28))
                    .foregroundStyle(weatherIconGradient(for: weather.iconName))

                Text(weather.conditionDescription)
                    .font(theme.typography.headlineMedium.font)
                    .foregroundColor(theme.colors.textPrimary.color)
                    .lineLimit(1)
            }

            // 気温 + 降水確率（横並び）
            HStack(spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.colors.error.color)
                    Text("\(weather.highTemperature)℃")
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.colors.info.color)
                    Text("\(weather.lowTemperature)℃")
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                HStack(spacing: 2) {
                    Image(systemName: "umbrella.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.colors.info.color)
                    Text("\(weather.precipitationChance)%")
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textSecondary.color)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.backgroundSecondary.color)
        )
    }

    private var weatherEmptyView: some View {
        Button {
            onSettingsTapped()
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.primaryBrand.color)

                Text("home_add_weather_location", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.primaryBrand.color)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textTertiary.color)
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )
        }
        .accessibilityIdentifier(AccessibilityID.addWeatherLocationButton)
    }

    private var weatherLoadingView: some View {
        HStack {
            ProgressView()
            Spacer()
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.backgroundSecondary.color)
        )
    }

    private var weatherErrorView: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(weatherLocations) { location in
                weatherErrorCard(location)
            }
        }
    }

    private func weatherErrorCard(_ location: WeatherLocation) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(location.label)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textSecondary.color)

            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "exclamationmark.icloud")
                    .font(.system(size: 32))
                    .foregroundColor(theme.colors.textTertiary.color)

                Text("home_weather_error", bundle: .app)
                    .font(theme.typography.captionSmall.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            }
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.backgroundSecondary.color)
        )
    }

    // MARK: - Weekly Section

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader(title: String(localized: "home_weekly_schedule", bundle: .app), icon: "calendar")

            VStack(spacing: 0) {
                weeklyGrid

                Divider()
                    .background(theme.colors.separator.color)
                    .padding(.top, theme.spacing.sm)

                legendView
                    .padding(.top, theme.spacing.sm)
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )
        }
    }

    private var weeklyGrid: some View {
        VStack(spacing: theme.spacing.xs) {
            // Day headers with date
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 36)

                ForEach(weekSchedule) { day in
                    VStack(spacing: 2) {
                        Text(day.dayOfMonth)
                            .font(theme.typography.captionSmall.font)
                            .foregroundColor(day.isToday ? theme.colors.primaryBrand.color : theme.colors.textTertiary.color)
                            .fontWeight(day.isToday ? .bold : .regular)
                        Text(day.dayOfWeek)
                            .font(theme.typography.captionLarge.font)
                            .foregroundColor(day.isToday ? theme.colors.primaryBrand.color : theme.colors.textSecondary.color)
                            .fontWeight(day.isToday ? .bold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Weather rows (one per location)
            ForEach(weeklyWeatherByLocation, id: \.location.id) { item in
                HStack(spacing: 0) {
                    Text(item.location.label)
                        .font(theme.typography.captionSmall.font)
                        .foregroundColor(theme.colors.textTertiary.color)
                        .frame(width: 36, alignment: .leading)
                        .lineLimit(1)

                    ForEach(weekSchedule) { day in
                        weeklyWeatherIcon(for: day.date, icons: item.icons)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            // Drop-off row
            HStack(spacing: 0) {
                Text("common_drop_off", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .frame(width: 36, alignment: .leading)

                ForEach(weekSchedule) { day in
                    weeklyCell(for: day.dropOff)
                        .frame(maxWidth: .infinity)
                }
            }

            // Pick-up row
            HStack(spacing: 0) {
                Text("common_pick_up", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .frame(width: 36, alignment: .leading)

                ForEach(weekSchedule) { day in
                    weeklyCell(for: day.pickUp)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private func weeklyCell(for status: HomeAssignmentStatus) -> some View {
        switch status {
        case .confirmed(let name):
            if name == currentUserName {
                Circle()
                    .fill(theme.colors.secondaryBrand.color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
            } else {
                Circle()
                    .stroke(theme.colors.separator.color, lineWidth: 1)
                    .frame(width: 28, height: 28)
            }
        case .unconfirmed:
            Circle()
                .fill(theme.colors.warning.color.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "exclamationmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.colors.warning.color)
                )
        case .noAssignee:
            Circle()
                .fill(theme.colors.error.color.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "exclamationmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.colors.error.color)
                )
        }
    }

    @ViewBuilder
    private func weeklyWeatherIcon(for date: Date, icons: [Date: String]) -> some View {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        if let iconName = icons[startOfDay] {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundStyle(weatherIconGradient(for: iconName))
        } else {
            // 天気データがない場合は空のスペース
            Color.clear
                .frame(width: 16, height: 16)
        }
    }

    private var legendView: some View {
        HStack(spacing: theme.spacing.md) {
            legendItem(color: theme.colors.secondaryBrand.color, text: String(localized: "home_legend_you", bundle: .app))
            legendItem(color: theme.colors.warning.color, text: String(localized: "home_legend_unconfirmed", bundle: .app), isWarning: true)
            legendItem(color: theme.colors.error.color, text: String(localized: "home_legend_needs_attention", bundle: .app), isError: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func legendItem(color: Color, text: String, isWarning: Bool = false, isError: Bool = false) -> some View {
        HStack(spacing: theme.spacing.xxs) {
            if isWarning || isError {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(color)
                    )
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
            }

            Text(text)
                .font(theme.typography.captionSmall.font)
                .foregroundColor(theme.colors.textSecondary.color)
        }
    }

    // MARK: - Owner Section

    private var ownerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            sectionHeader(title: String(localized: "home_owner_section", bundle: .app), icon: "person.badge.key")

            Button {
                onDecideAssigneeTapped()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text("home_decide_assignee", bundle: .app)
                            .font(theme.typography.headlineMedium.font)
                            .foregroundColor(theme.colors.textPrimary.color)

                        Text("home_decide_assignee_description", bundle: .app)
                            .font(theme.typography.bodySmall.font)
                            .foregroundColor(theme.colors.textSecondary.color)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.colors.textTertiary.color)
                }
                .padding(theme.spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                        .fill(theme.colors.backgroundSecondary.color)
                )
            }
            .accessibilityIdentifier(AccessibilityID.decideAssigneeButton)
        }
    }

    // MARK: - Warnings Section

    private var warningsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            let sortedWarnings = warnings.sorted { w1, w2 in
                switch (w1.type, w2.type) {
                case (.noAssignee, .unconfirmed): return true
                case (.unconfirmed, .noAssignee): return false
                default: return false
                }
            }

            if !sortedWarnings.isEmpty {
                let visibleWarnings = isWarningsExpanded
                    ? sortedWarnings
                    : Array(sortedWarnings.prefix(maxVisibleWarnings))

                ForEach(visibleWarnings) { warning in
                    warningRow(warning)
                }

                // 「すべて表示」ボタン（警告が3件より多い場合のみ）
                if sortedWarnings.count > maxVisibleWarnings {
                    Button {
                        if isWarningsExpanded {
                            // 折りたたむときはアニメーションなし
                            isWarningsExpanded = false
                        } else {
                            // 展開するときはアニメーションあり
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isWarningsExpanded = true
                            }
                        }
                    } label: {
                        HStack(spacing: theme.spacing.xxs) {
                            Text(isWarningsExpanded ? String(localized: "home_collapse", bundle: .app) : String(format: String(localized: "home_show_all", bundle: .app), sortedWarnings.count))
                                .font(theme.typography.bodySmall.font)

                            Image(systemName: isWarningsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(theme.colors.primaryBrand.color)
                    }
                    .accessibilityIdentifier(AccessibilityID.toggleWarningsButton)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, theme.spacing.xxs)
                }
            }
        }
    }

    private func warningRow(_ warning: HomeWarning) -> some View {
        let (icon, iconColor, backgroundColor) = warningStyle(for: warning.type)

        return HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(iconColor)

            Text(warning.message)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Spacer()
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                .fill(backgroundColor)
        )
    }

    private func warningStyle(for type: HomeWarning.WarningType) -> (String, Color, Color) {
        switch type {
        case .noAssignee:
            return (
                "exclamationmark.circle.fill",
                theme.colors.error.color,
                theme.colors.error.color.opacity(0.12)
            )
        case .unconfirmed:
            return (
                "questionmark.circle.fill",
                theme.colors.warning.color,
                theme.colors.warning.color.opacity(0.12)
            )
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.colors.primaryBrand.color)

            Text(title)
                .font(theme.typography.headlineLarge.font)
                .foregroundColor(theme.colors.textPrimary.color)
        }
    }

    private func weatherIconGradient(for iconName: String) -> some ShapeStyle {
        switch iconName {
        case let name where name.contains("sun.max"):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.orange, Color.yellow],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case let name where name.contains("cloud.sun"):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.yellow, Color.gray],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case let name where name.contains("cloud.bolt"):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.purple, Color.gray],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case let name where name.contains("cloud.rain"), let name where name.contains("cloud.drizzle"):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.blue, Color.gray],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case let name where name.contains("cloud.snow"):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cyan, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case let name where name.contains("cloud"):
            return AnyShapeStyle(Color.gray)
        case let name where name.contains("moon"):
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.indigo, Color.yellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyShapeStyle(theme.colors.info.color)
        }
    }
}

// MARK: - Preview

#Preview("HomeView_Okumuka") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today

    let weekSchedule = (0..<7).map { dayOffset -> HomeDaySchedule in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        let isEven = dayOffset % 2 == 0
        return HomeDaySchedule(
            date: date,
            dropOff: .confirmed(personName: isEven ? "Papa" : "Mama"),
            pickUp: .confirmed(personName: isEven ? "Mama" : "Papa")
        )
    }

    let weatherLocations = [
        WeatherLocation(label: "家", latitude: 35.68, longitude: 139.76, placeName: "東京都", userGroupID: UUID()),
        WeatherLocation(label: "保育園", latitude: 35.69, longitude: 139.77, placeName: "東京都", userGroupID: UUID())
    ]

    let weathers = [
        HomeWeatherData(
            locationID: UUID(),
            locationLabel: "家",
            targetDate: today,
            iconName: "sun.max.fill",
            condition: .clear,
            highTemperature: 22,
            lowTemperature: 14,
            precipitationChance: 10
        ),
        HomeWeatherData(
            locationID: UUID(),
            locationLabel: "保育園",
            targetDate: today,
            iconName: "cloud.sun.fill",
            condition: .partlyCloudy,
            highTemperature: 21,
            lowTemperature: 13,
            precipitationChance: 20
        )
    ]

    // プレビュー用の週間天気アイコン（地点別）
    let weeklyWeatherByLocation: [(location: WeatherLocation, icons: [Date: String])] = weatherLocations.enumerated().map { index, location in
        let icons: [Date: String] = Dictionary(
            uniqueKeysWithValues: weekSchedule.map { day in
                let iconOptions = index == 0
                    ? ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.rain.fill", "sun.max.fill", "cloud.sun.fill", "sun.max.fill"]
                    : ["cloud.sun.fill", "sun.max.fill", "cloud.rain.fill", "cloud.fill", "cloud.sun.fill", "sun.max.fill", "cloud.fill"]
                let dayIndex = calendar.component(.weekday, from: day.date) % 7
                return (calendar.startOfDay(for: day.date), iconOptions[dayIndex])
            }
        )
        return (location: location, icons: icons)
    }

    // プレビュー用の複数グループ
    let groups = [
        UserGroup(name: "山田家"),
        UserGroup(name: "田中家")
    ]

    return HomeView_Okumuka(
        groupName: "山田家",
        groups: groups,
        todayDropOff: .confirmed(personName: "Papa"),
        todayPickUp: .confirmed(personName: "Mama"),
        weatherLocations: weatherLocations,
        weathers: weathers,
        weatherTargetDate: today,
        weekSchedule: weekSchedule,
        weeklyWeatherByLocation: weeklyWeatherByLocation,
        warnings: [],
        currentUserName: "Papa",
        isLoadingWeather: false,
        isOwner: true,
        onScheduleInputTapped: {},
        onSettingsTapped: {},
        onDecideAssigneeTapped: {},
        onGroupSelected: { _ in },
        onCreateGroupTapped: {},
        onRefresh: {}
    )
}

#Preview("HomeView_Okumuka - ManyWarnings") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today

    let weekSchedule = (0..<7).map { dayOffset -> HomeDaySchedule in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return HomeDaySchedule(
            date: date,
            dropOff: dayOffset < 3 ? .noAssignee : .unconfirmed,
            pickUp: .unconfirmed
        )
    }

    let warnings = [
        HomeWarning(type: .noAssignee, message: "月曜日の送りの担当者がいません"),
        HomeWarning(type: .noAssignee, message: "火曜日の送りの担当者がいません"),
        HomeWarning(type: .noAssignee, message: "水曜日の送りの担当者がいません"),
        HomeWarning(type: .unconfirmed, message: "木曜日の送りが未確定です"),
        HomeWarning(type: .unconfirmed, message: "金曜日の送りが未確定です"),
        HomeWarning(type: .unconfirmed, message: "土曜日の迎えが未確定です"),
    ]

    let weatherLocations = [
        WeatherLocation(label: "家", latitude: 35.68, longitude: 139.76, placeName: "東京都", userGroupID: UUID())
    ]

    let weathers = [
        HomeWeatherData(
            locationID: UUID(),
            locationLabel: "家",
            targetDate: today,
            iconName: "cloud.rain.fill",
            condition: .rain,
            highTemperature: 18,
            lowTemperature: 12,
            precipitationChance: 80
        )
    ]

    return HomeView_Okumuka(
        groupName: "山田家",
        groups: [UserGroup(name: "山田家")],
        todayDropOff: .noAssignee,
        todayPickUp: .unconfirmed,
        weatherLocations: weatherLocations,
        weathers: weathers,
        weatherTargetDate: today,
        weekSchedule: weekSchedule,
        weeklyWeatherByLocation: [],
        warnings: warnings,
        currentUserName: "Papa",
        isLoadingWeather: false,
        isOwner: true,
        onScheduleInputTapped: {},
        onSettingsTapped: {},
        onDecideAssigneeTapped: {},
        onGroupSelected: { _ in },
        onCreateGroupTapped: {},
        onRefresh: {}
    )
}

#Preview("HomeView_Okumuka - EmptyWeather") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today

    let weekSchedule = (0..<7).map { dayOffset -> HomeDaySchedule in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return HomeDaySchedule(
            date: date,
            dropOff: .confirmed(personName: "Papa"),
            pickUp: .confirmed(personName: "Mama")
        )
    }

    return HomeView_Okumuka(
        groupName: "山田家",
        groups: [UserGroup(name: "山田家")],
        todayDropOff: .confirmed(personName: "Papa"),
        todayPickUp: .confirmed(personName: "Mama"),
        weatherLocations: [],
        weathers: [],
        weatherTargetDate: nil,
        weekSchedule: weekSchedule,
        weeklyWeatherByLocation: [],
        warnings: [],
        currentUserName: "Papa",
        isLoadingWeather: false,
        isOwner: false,
        onScheduleInputTapped: {},
        onSettingsTapped: {},
        onDecideAssigneeTapped: {},
        onGroupSelected: { _ in },
        onCreateGroupTapped: {},
        onRefresh: {}
    )
}

#Preview("HomeView_Okumuka - WeatherError") {
    let calendar = PreviewDate.calendar
    let today = PreviewDate.today

    let weekSchedule = (0..<7).map { dayOffset -> HomeDaySchedule in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return HomeDaySchedule(
            date: date,
            dropOff: .confirmed(personName: "Papa"),
            pickUp: .confirmed(personName: "Mama")
        )
    }

    let weatherLocations = [
        WeatherLocation(label: "保育園", latitude: 35.68, longitude: 139.76, placeName: "東京都", userGroupID: UUID())
    ]

    return HomeView_Okumuka(
        groupName: "山田家",
        groups: [UserGroup(name: "山田家")],
        todayDropOff: .confirmed(personName: "Papa"),
        todayPickUp: .confirmed(personName: "Mama"),
        weatherLocations: weatherLocations,
        weathers: [],
        weatherTargetDate: today,
        weekSchedule: weekSchedule,
        weeklyWeatherByLocation: [],
        warnings: [],
        currentUserName: "Papa",
        isLoadingWeather: false,
        isOwner: true,
        onScheduleInputTapped: {},
        onSettingsTapped: {},
        onDecideAssigneeTapped: {},
        onGroupSelected: { _ in },
        onCreateGroupTapped: {},
        onRefresh: {}
    )
}

#Preview("Colorful Tiles_Okumuka") {
    VStack(spacing: 40) {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.pink)
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.cyan)
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange)
    }
    .padding(40)
}
