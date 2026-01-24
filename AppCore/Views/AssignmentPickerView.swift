import Prefire
import SwiftUI

// MARK: - Member Availability

/// メンバーの可用性状態
public enum MemberAvailabilityStatus: Sendable {
    case ok      // OKを入力済み
    case ng      // NGを入力済み
    case notSet  // 未入力

    var isSelectable: Bool {
        self == .ok
    }
}

/// メンバーと可用性のペア
public struct MemberWithAvailability: Identifiable, Sendable {
    public var id: String { member.participantID }
    public let member: GroupMember
    public let status: MemberAvailabilityStatus

    public init(member: GroupMember, status: MemberAvailabilityStatus) {
        self.member = member
        self.status = status
    }
}

/// 1日分のUI用割り当てデータ
public struct DayAssignmentUI: Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    public var dropOffMembers: [MemberWithAvailability]
    public var pickUpMembers: [MemberWithAvailability]
    public var selectedDropOffMember: GroupMember?
    public var selectedPickUpMember: GroupMember?

    public init(
        id: UUID = UUID(),
        date: Date,
        dropOffMembers: [MemberWithAvailability] = [],
        pickUpMembers: [MemberWithAvailability] = [],
        selectedDropOffMember: GroupMember? = nil,
        selectedPickUpMember: GroupMember? = nil
    ) {
        self.id = id
        self.date = date
        self.dropOffMembers = dropOffMembers
        self.pickUpMembers = pickUpMembers
        self.selectedDropOffMember = selectedDropOffMember
        self.selectedPickUpMember = selectedPickUpMember
    }

    var hasDropOffWarning: Bool {
        !dropOffMembers.contains { $0.status == .ok }
    }

    var hasPickUpWarning: Bool {
        !pickUpMembers.contains { $0.status == .ok }
    }
}

// MARK: - AssignmentPickerView

/// 担当者選択View
public struct AssignmentPickerView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case dayRow(dayIndex: Int)
        case saveButton
        case memberRow(participantID: String)

        public var rawIdentifier: String {
            switch self {
            case .dayRow(let dayIndex):
                return "assignmentPicker_row_day\(dayIndex)"
            case .saveButton:
                return "assignmentPicker_button_save"
            case .memberRow(let participantID):
                return "assignmentPicker_row_member_\(participantID)"
            }
        }
    }

    let assignments: [DayAssignmentUI]
    let onDropOffSelected: (Int, GroupMember?) -> Void
    let onPickUpSelected: (Int, GroupMember?) -> Void
    let onSave: () -> Void

    private let theme = DesignSystem.default

    public init(
        assignments: [DayAssignmentUI],
        onDropOffSelected: @escaping (Int, GroupMember?) -> Void,
        onPickUpSelected: @escaping (Int, GroupMember?) -> Void,
        onSave: @escaping () -> Void
    ) {
        self.assignments = assignments
        self.onDropOffSelected = onDropOffSelected
        self.onPickUpSelected = onPickUpSelected
        self.onSave = onSave
    }

    public var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                scheduleContent
                saveButtonArea
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: theme.spacing.xs) {
            Text("担当者を決める")
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Text("各日の送り迎えの担当者を選んでください")
                .font(theme.typography.bodySmall.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, theme.spacing.lg)
        .padding(.horizontal, theme.spacing.md)
    }

    // MARK: - Schedule Content

    private var scheduleContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(assignments.enumerated()), id: \.element.id) { index, assignment in
                    AssignmentDayRowView(
                        assignment: assignment,
                        theme: theme,
                        onDropOffSelected: { member in onDropOffSelected(index, member) },
                        onPickUpSelected: { member in onPickUpSelected(index, member) }
                    )
                    .accessibilityIdentifier(AccessibilityID.dayRow(dayIndex: index))

                    if index < assignments.count - 1 {
                        Divider()
                            .background(theme.colors.separator.color)
                            .padding(.leading, theme.spacing.md)
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

    // MARK: - Save Button

    private var saveButtonArea: some View {
        VStack(spacing: theme.spacing.xs) {
            Button {
                onSave()
            } label: {
                Text("保存する")
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.saveButton)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
        .background(
            theme.colors.backgroundPrimary.color
                .shadow(color: theme.colors.textPrimary.color.opacity(0.06), radius: 8, x: 0, y: -4)
        )
    }
}

// MARK: - Assignment Day Row View

struct AssignmentDayRowView: View {
    let assignment: DayAssignmentUI
    let theme: DesignSystem
    let onDropOffSelected: (GroupMember?) -> Void
    let onPickUpSelected: (GroupMember?) -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter
    }

    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            // Date header
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xxs) {
                Text(dateFormatter.string(from: assignment.date))
                    .font(theme.typography.headlineLarge.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text(weekdayFormatter.string(from: assignment.date))
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }

            // Drop off section
            AssignmentSectionView(
                title: "送り",
                members: assignment.dropOffMembers,
                selectedMember: assignment.selectedDropOffMember,
                hasWarning: assignment.hasDropOffWarning,
                theme: theme,
                onMemberSelected: onDropOffSelected
            )

            // Pick up section
            AssignmentSectionView(
                title: "迎え",
                members: assignment.pickUpMembers,
                selectedMember: assignment.selectedPickUpMember,
                hasWarning: assignment.hasPickUpWarning,
                theme: theme,
                onMemberSelected: onPickUpSelected
            )
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
    }
}

// MARK: - Assignment Section View

struct AssignmentSectionView: View {
    let title: String
    let members: [MemberWithAvailability]
    let selectedMember: GroupMember?
    let hasWarning: Bool
    let theme: DesignSystem
    let onMemberSelected: (GroupMember?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Section header
            HStack(spacing: theme.spacing.xxs) {
                Text(title)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textSecondary.color)

                if hasWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.warning.color)
                }
            }

            // Members list
            VStack(spacing: theme.spacing.xs) {
                ForEach(members) { availability in
                    AssignmentMemberRowView(
                        member: availability.member,
                        status: availability.status,
                        isSelected: selectedMember?.participantID == availability.member.participantID,
                        hasSelection: selectedMember != nil,
                        theme: theme,
                        onTap: {
                            guard availability.status.isSelectable else { return }
                            withAnimation(.easeOut(duration: 0.1)) {
                                if selectedMember?.participantID == availability.member.participantID {
                                    onMemberSelected(nil)
                                } else {
                                    onMemberSelected(availability.member)
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Assignment Member Row View

struct AssignmentMemberRowView: View {
    let member: GroupMember
    let status: MemberAvailabilityStatus
    let isSelected: Bool
    let hasSelection: Bool
    let theme: DesignSystem
    let onTap: () -> Void

    private var isDisabled: Bool {
        !status.isSelectable
    }

    private var isDimmed: Bool {
        isDisabled || (hasSelection && !isSelected)
    }

    private var iconColor: Color {
        // メンバーのparticipantIDから決定的なハッシュを計算して色を決定
        // Note: hashValueは実行ごとに異なるため、djb2アルゴリズムを使用
        let hash = member.participantID.utf8.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
        let colors: [Color] = [
            Color(hex: "5A8FB8"),
            Color(hex: "E8AA8C"),
            Color(hex: "5A9E6F"),
            Color(hex: "D4A24C"),
            Color(hex: "8B5CF6"),
            Color(hex: "EC4899")
        ]
        return colors[abs(hash) % colors.count]
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: theme.spacing.sm) {
                // Avatar
                Circle()
                    .fill(isDisabled ? Color.gray.opacity(0.5) : iconColor)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(member.displayName.prefix(1)))
                            .font(theme.typography.bodyMedium.font)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    )

                // Name
                Text(member.displayName)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(isSelected ? .white : theme.colors.textPrimary.color)

                Spacer()

                // Status icon
                AssignmentStatusIconView(status: status, theme: theme)
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(isSelected ? theme.colors.secondaryBrand.color : theme.colors.backgroundTertiary.color)
            )
            .opacity(isDimmed ? 0.4 : 1.0)
        }
        .disabled(isDisabled)
        .buttonStyle(AssignmentMemberRowButtonStyle())
        .accessibilityIdentifier(AssignmentPickerView.AccessibilityID.memberRow(participantID: member.participantID))
    }
}

struct AssignmentMemberRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Assignment Status Icon View

struct AssignmentStatusIconView: View {
    let status: MemberAvailabilityStatus
    let theme: DesignSystem

    private var iconColor: Color {
        switch status {
        case .ok:
            return theme.colors.secondaryBrand.color
        case .ng:
            return theme.colors.error.color
        case .notSet:
            return theme.colors.textTertiary.color.opacity(0.5)
        }
    }

    private var iconName: String {
        switch status {
        case .ok: return "circle"
        case .ng: return "xmark"
        case .notSet: return "questionmark"
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(iconColor)
            .frame(width: 24, height: 24)
    }
}

// MARK: - Preview

#Preview("AssignmentPickerView") {
    AssignmentPickerView(
        assignments: DayAssignmentUI.mockWeek(),
        onDropOffSelected: { _, _ in },
        onPickUpSelected: { _, _ in },
        onSave: {}
    )
    .prefireEnabled()
}

#Preview("AssignmentPickerView - DarkMode") {
    AssignmentPickerView(
        assignments: DayAssignmentUI.mockWeek(),
        onDropOffSelected: { _, _ in },
        onPickUpSelected: { _, _ in },
        onSave: {}
    )
    .preferredColorScheme(.dark)
    .prefireEnabled()
}

// MARK: - Mock Data for Preview

extension GroupMember {
    static let previewPapa = GroupMember(participantID: "papa", displayName: "パパ", isOwner: true)
    static let previewMama = GroupMember(participantID: "mama", displayName: "ママ", isOwner: false)
    static let previewGrandma = GroupMember(participantID: "grandma", displayName: "おばあちゃん", isOwner: false)
}

extension DayAssignmentUI {
    static func mockWeek(from startDate: Date = PreviewDate.today) -> [DayAssignmentUI] {
        let calendar = Calendar(identifier: .gregorian)
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            return DayAssignmentUI(
                date: date,
                dropOffMembers: [
                    MemberWithAvailability(member: .previewPapa, status: .ok),
                    MemberWithAvailability(member: .previewMama, status: .ok),
                    MemberWithAvailability(member: .previewGrandma, status: .ng)
                ],
                pickUpMembers: [
                    MemberWithAvailability(member: .previewPapa, status: .ok),
                    MemberWithAvailability(member: .previewMama, status: .ok),
                    MemberWithAvailability(member: .previewGrandma, status: .ok)
                ]
            )
        }
    }
}
