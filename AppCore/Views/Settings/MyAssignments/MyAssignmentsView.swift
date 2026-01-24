import Prefire
import SwiftUI

/// 自分の担当一覧画面（パラメータベース）
struct MyAssignmentsView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case doneButton
        case assignmentRow(id: UUID)

        public var rawIdentifier: String {
            switch self {
            case .doneButton:
                return "myAssignments_button_done"
            case .assignmentRow(let id):
                return "myAssignments_row_\(id.uuidString)"
            }
        }
    }

    // MARK: - Parameters

    let assignmentsByDate: [Date: [MyAssignmentItem]]
    let sortedDates: [Date]
    let isLoading: Bool
    let errorMessage: String?

    // MARK: - Actions

    let onRefresh: () -> Void
    let onDismiss: () -> Void

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                if isLoading && assignmentsByDate.isEmpty {
                    ProgressView()
                } else if sortedDates.isEmpty {
                    emptyView
                } else {
                    contentList
                }
            }
            .navigationTitle(String(localized: "my_assignments_title", bundle: .app))
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

    // MARK: - Subviews

    private var emptyView: some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(theme.colors.textTertiary.color)

            Text("my_assignments_empty", bundle: .app)
                .font(theme.typography.bodyLarge.font)
                .foregroundColor(theme.colors.textSecondary.color)
        }
    }

    private var contentList: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.lg, pinnedViews: [.sectionHeaders]) {
                ForEach(sortedDates, id: \.self) { date in
                    Section {
                        VStack(spacing: 0) {
                            if let items = assignmentsByDate[date] {
                                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                    assignmentRow(item)

                                    if index < items.count - 1 {
                                        SettingsDivider()
                                    }
                                }
                            }
                        }
                        .background(theme.colors.backgroundSecondary.color)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
                    } header: {
                        dateSectionHeader(date)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.md)
        }
        .refreshable {
            onRefresh()
        }
    }

    private func dateSectionHeader(_ date: Date) -> some View {
        HStack {
            Text(formatDate(date))
                .font(theme.typography.headlineSmall.font)
                .foregroundColor(theme.colors.textPrimary.color)
            Spacer()
        }
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.backgroundPrimary.color)
    }

    private func assignmentRow(_ item: MyAssignmentItem) -> some View {
        HStack(spacing: theme.spacing.sm) {
            // アイコン
            Image(systemName: item.assignmentType == .dropOff ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 20))
                .foregroundColor(item.assignmentType == .dropOff ? .orange : .indigo)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                // グループ名
                Text(item.groupName)
                    .font(theme.typography.bodyLarge.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                // 送り/迎え
                Text(item.assignmentType == .dropOff
                     ? String(localized: "assignment_type_dropoff", bundle: .app)
                     : String(localized: "assignment_type_pickup", bundle: .app))
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .accessibilityIdentifier(AccessibilityID.assignmentRow(id: item.id))
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("MyAssignmentsView - Empty") {
    MyAssignmentsView(
        assignmentsByDate: [:],
        sortedDates: [],
        isLoading: false,
        errorMessage: nil,
        onRefresh: {},
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("MyAssignmentsView - WithAssignments") {
    // スナップショットテストのため固定日付を使用
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2025
    components.month = 1
    components.day = 15
    let baseDate = calendar.date(from: components)!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: baseDate)!
    let dayAfter = calendar.date(byAdding: .day, value: 2, to: baseDate)!

    let groupAID = UUID()
    let groupBID = UUID()

    let items: [MyAssignmentItem] = [
        MyAssignmentItem(date: tomorrow, groupID: groupAID, groupName: "おくむか保育園", assignmentType: .dropOff),
        MyAssignmentItem(date: tomorrow, groupID: groupBID, groupName: "ひまわり保育園", assignmentType: .pickUp),
        MyAssignmentItem(date: dayAfter, groupID: groupAID, groupName: "おくむか保育園", assignmentType: .dropOff),
        MyAssignmentItem(date: dayAfter, groupID: groupAID, groupName: "おくむか保育園", assignmentType: .pickUp)
    ]

    let assignmentsByDate = MyAssignmentsReducer.groupByDate(items)
    let sortedDates = assignmentsByDate.keys.sorted()

    return MyAssignmentsView(
        assignmentsByDate: assignmentsByDate,
        sortedDates: sortedDates,
        isLoading: false,
        errorMessage: nil,
        onRefresh: {},
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("MyAssignmentsView - Loading") {
    MyAssignmentsView(
        assignmentsByDate: [:],
        sortedDates: [],
        isLoading: true,
        errorMessage: nil,
        onRefresh: {},
        onDismiss: {}
    )
    .prefireEnabled()
}
