import SwiftUI

// MARK: - Mock Data Models

/// Mock user for prototype
struct MockMember: Identifiable, Equatable {
    let id: UUID
    let name: String
    let iconColor: Color

    init(id: UUID = UUID(), name: String, iconColor: Color) {
        self.id = id
        self.name = name
        self.iconColor = iconColor
    }
}

/// Assignment type
enum AssignmentType: String, CaseIterable {
    case dropOff = "送り"
    case pickUp = "迎え"
}

/// Member availability status
enum AvailabilityStatus {
    case ok
    case ng
    case notEntered

    var isSelectable: Bool {
        self == .ok
    }

    var label: String {
        switch self {
        case .ok: return "◯"
        case .ng: return "✗"
        case .notEntered: return "?"
        }
    }
}

/// Member with availability status
struct MemberAvailability: Identifiable {
    var id: UUID { member.id }
    let member: MockMember
    let status: AvailabilityStatus
}

/// Daily assignment data (Prototype用)
struct PrototypeDayAssignment: Identifiable {
    let id: UUID
    let date: Date
    var dropOffMembers: [MemberAvailability]
    var pickUpMembers: [MemberAvailability]
    var selectedDropOff: MockMember?
    var selectedPickUp: MockMember?

    init(
        id: UUID = UUID(),
        date: Date,
        dropOffMembers: [MemberAvailability] = [],
        pickUpMembers: [MemberAvailability] = [],
        selectedDropOff: MockMember? = nil,
        selectedPickUp: MockMember? = nil
    ) {
        self.id = id
        self.date = date
        self.dropOffMembers = dropOffMembers
        self.pickUpMembers = pickUpMembers
        self.selectedDropOff = selectedDropOff
        self.selectedPickUp = selectedPickUp
    }

    var hasDropOffWarning: Bool {
        !dropOffMembers.contains { $0.status == .ok }
    }

    var hasPickUpWarning: Bool {
        !pickUpMembers.contains { $0.status == .ok }
    }
}

// MARK: - Main View

/// Assignment Picker Prototype View
struct AssignmentPickerPrototype: View {
    @State private var assignments: [PrototypeDayAssignment]

    private let theme = DesignSystem.default

    init(assignments: [PrototypeDayAssignment]) {
        _assignments = State(initialValue: assignments)
    }

    var body: some View {
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
                    PrototypeDayAssignmentRow(
                        assignment: binding(for: index),
                        theme: theme
                    )
                    .accessibilityIdentifier("assignmentPicker_row_day\(index)")

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
                // Save action
            } label: {
                Text("保存する")
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier("assignmentPicker_button_save")
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
        .background(
            theme.colors.backgroundPrimary.color
                .shadow(color: theme.colors.textPrimary.color.opacity(0.06), radius: 8, x: 0, y: -4)
        )
    }

    // MARK: - Helper

    private func binding(for index: Int) -> Binding<PrototypeDayAssignment> {
        Binding(
            get: { assignments[index] },
            set: { assignments[index] = $0 }
        )
    }
}

// MARK: - Day Assignment Row

struct PrototypeDayAssignmentRow: View {
    @Binding var assignment: PrototypeDayAssignment
    let theme: DesignSystem

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
            AssignmentSection(
                type: .dropOff,
                members: assignment.dropOffMembers,
                selectedMember: $assignment.selectedDropOff,
                theme: theme
            )

            // Pick up section
            AssignmentSection(
                type: .pickUp,
                members: assignment.pickUpMembers,
                selectedMember: $assignment.selectedPickUp,
                theme: theme
            )
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
    }
}

// MARK: - Assignment Section

struct AssignmentSection: View {
    let type: AssignmentType
    let members: [MemberAvailability]
    @Binding var selectedMember: MockMember?
    let theme: DesignSystem

    private var hasWarning: Bool {
        !members.contains { $0.status == .ok }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Section header
            HStack(spacing: theme.spacing.xxs) {
                Text(type.rawValue)
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
                    MemberRow(
                        member: availability.member,
                        status: availability.status,
                        isSelected: selectedMember?.id == availability.member.id,
                        hasSelection: selectedMember != nil,
                        theme: theme,
                        onTap: {
                            guard availability.status.isSelectable else { return }
                            withAnimation(.easeOut(duration: 0.1)) {
                                if selectedMember?.id == availability.member.id {
                                    selectedMember = nil
                                } else {
                                    selectedMember = availability.member
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Member Row

struct MemberRow: View {
    let member: MockMember
    let status: AvailabilityStatus
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

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: theme.spacing.sm) {
                // Avatar
                Circle()
                    .fill(isDisabled ? Color.gray.opacity(0.5) : member.iconColor)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(member.name.prefix(1)))
                            .font(theme.typography.bodyMedium.font)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    )

                // Name
                Text(member.name)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(isSelected ? .white : theme.colors.textPrimary.color)

                Spacer()

                // Status badge
                StatusBadge(status: status, theme: theme)
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
        .buttonStyle(MemberRowButtonStyle())
        .accessibilityIdentifier("assignmentPicker_row_member_\(member.id.uuidString)")
    }
}

struct MemberRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: AvailabilityStatus
    let theme: DesignSystem

    private var backgroundColor: Color {
        switch status {
        case .ok:
            return theme.colors.secondaryBrand.color.opacity(0.18)
        case .ng:
            return theme.colors.error.color.opacity(0.15)
        case .notEntered:
            return theme.colors.backgroundTertiary.color
        }
    }

    private var iconColor: Color {
        switch status {
        case .ok:
            return theme.colors.secondaryBrand.color
        case .ng:
            return theme.colors.error.color
        case .notEntered:
            return theme.colors.textTertiary.color.opacity(0.5)
        }
    }

    private var iconName: String {
        switch status {
        case .ok: return "circle"
        case .ng: return "xmark"
        case .notEntered: return "questionmark"
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(iconColor)
            .frame(width: 24, height: 24)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                let position = result.positions[index]
                subview.place(
                    at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                    proposal: ProposedViewSize(subview.sizeThatFits(.unspecified))
                )
            }
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity

        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))

            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalHeight = currentY + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

// MARK: - Mock Data

extension MockMember {
    static let papa = MockMember(name: "パパ", iconColor: Color(hex: "5A8FB8"))
    static let mama = MockMember(name: "ママ", iconColor: Color(hex: "E8AA8C"))
    static let grandpa = MockMember(name: "おじいちゃん", iconColor: Color(hex: "5A9E6F"))
    static let grandma = MockMember(name: "おばあちゃん", iconColor: Color(hex: "D4A24C"))
    static let uncle = MockMember(name: "おじさん", iconColor: Color(hex: "8B5CF6"))
    static let aunt = MockMember(name: "おばさん", iconColor: Color(hex: "EC4899"))
}

extension PrototypeDayAssignment {
    static func mockWeek(from startDate: Date = Date()) -> [PrototypeDayAssignment] {
        let calendar = Calendar(identifier: .gregorian)
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            return PrototypeDayAssignment(
                date: date,
                dropOffMembers: [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandma, status: .ng)
                ],
                pickUpMembers: [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandma, status: .ok)
                ]
            )
        }
    }

    static func mockWeekWithWarnings(from startDate: Date = Date()) -> [PrototypeDayAssignment] {
        let calendar = Calendar(identifier: .gregorian)
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!

            // Day 2 and 5: all NG for drop-off
            let dropOffMembers: [MemberAvailability] = (offset == 2 || offset == 5)
                ? [
                    MemberAvailability(member: .papa, status: .ng),
                    MemberAvailability(member: .mama, status: .ng),
                    MemberAvailability(member: .grandma, status: .notEntered)
                ]
                : [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandma, status: .ng)
                ]

            // Day 3: all NG/未入力 for pick-up
            let pickUpMembers: [MemberAvailability] = offset == 3
                ? [
                    MemberAvailability(member: .papa, status: .ng),
                    MemberAvailability(member: .mama, status: .notEntered),
                    MemberAvailability(member: .grandma, status: .ng)
                ]
                : [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandma, status: .ok)
                ]

            return PrototypeDayAssignment(
                date: date,
                dropOffMembers: dropOffMembers,
                pickUpMembers: pickUpMembers
            )
        }
    }

    static func mockWeekAllSelected(from startDate: Date = Date()) -> [PrototypeDayAssignment] {
        let calendar = Calendar(identifier: .gregorian)
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            return PrototypeDayAssignment(
                date: date,
                dropOffMembers: [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandma, status: .ng)
                ],
                pickUpMembers: [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandma, status: .ok)
                ],
                selectedDropOff: offset % 2 == 0 ? .papa : .mama,
                selectedPickUp: offset % 3 == 0 ? .grandma : (offset % 3 == 1 ? .papa : .mama)
            )
        }
    }

    static func mockWeekManyCandidates(from startDate: Date = Date()) -> [PrototypeDayAssignment] {
        let calendar = Calendar(identifier: .gregorian)
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            return PrototypeDayAssignment(
                date: date,
                dropOffMembers: [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandpa, status: .ng),
                    MemberAvailability(member: .grandma, status: .notEntered)
                ],
                pickUpMembers: [
                    MemberAvailability(member: .papa, status: .ok),
                    MemberAvailability(member: .mama, status: .ok),
                    MemberAvailability(member: .grandpa, status: .ok),
                    MemberAvailability(member: .grandma, status: .ok),
                    MemberAvailability(member: .uncle, status: .ng),
                    MemberAvailability(member: .aunt, status: .notEntered)
                ]
            )
        }
    }
}

// MARK: - Previews

#Preview("Normal State") {
    AssignmentPickerPrototype(
        assignments: PrototypeDayAssignment.mockWeek(from: PreviewDate.today)
    )
}

#Preview("With Warnings") {
    AssignmentPickerPrototype(
        assignments: PrototypeDayAssignment.mockWeekWithWarnings(from: PreviewDate.today)
    )
}

#Preview("All Selected") {
    AssignmentPickerPrototype(
        assignments: PrototypeDayAssignment.mockWeekAllSelected(from: PreviewDate.today)
    )
}

#Preview("Many Candidates") {
    AssignmentPickerPrototype(
        assignments: PrototypeDayAssignment.mockWeekManyCandidates(from: PreviewDate.today)
    )
}

#Preview("Dark Mode") {
    AssignmentPickerPrototype(
        assignments: PrototypeDayAssignment.mockWeek(from: PreviewDate.today)
    )
    .preferredColorScheme(.dark)
}
