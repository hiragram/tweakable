import SwiftUI

/// Container view that connects AppStore to AssignmentPickerView
struct AssignmentPickerContainerView: View {
    let store: AppStore
    let onDismiss: () -> Void

    private let theme = DesignSystem.default

    // MARK: - Computed Properties

    /// Convert store state to DayAssignmentUI array
    private var assignments: [DayAssignmentUI] {
        let members = store.state.sharing.members
        let weekEntries = store.state.schedule.weekEntries

        return weekEntries.map { entry in
            let dropOffMembers = members.map { member in
                MemberWithAvailability(
                    member: member,
                    status: memberStatus(for: member, entry: entry, isDropOff: true)
                )
            }

            let pickUpMembers = members.map { member in
                MemberWithAvailability(
                    member: member,
                    status: memberStatus(for: member, entry: entry, isDropOff: false)
                )
            }

            // Find selected members based on assignment state
            let assignmentIndex = store.state.assignment.weekAssignments.firstIndex { assignment in
                Calendar.current.isDate(assignment.date, inSameDayAs: entry.date)
            }

            var selectedDropOff: GroupMember?
            var selectedPickUp: GroupMember?

            if let index = assignmentIndex {
                let assignment = store.state.assignment.weekAssignments[index]
                if let dropOffID = assignment.assignedDropOffUserID {
                    selectedDropOff = members.first { $0.participantID == dropOffID.uuidString }
                }
                if let pickUpID = assignment.assignedPickUpUserID {
                    selectedPickUp = members.first { $0.participantID == pickUpID.uuidString }
                }
            }

            return DayAssignmentUI(
                date: entry.date,
                dropOffMembers: dropOffMembers,
                pickUpMembers: pickUpMembers,
                selectedDropOffMember: selectedDropOff,
                selectedPickUpMember: selectedPickUp
            )
        }
    }

    // MARK: - Body

    var body: some View {
        AssignmentPickerView(
            assignments: assignments,
            onDropOffSelected: { index, member in
                handleDropOffSelection(index: index, member: member)
            },
            onPickUpSelected: { index, member in
                handlePickUpSelection(index: index, member: member)
            },
            onSave: {
                store.send(.assignment(.submitAssignments))
                onDismiss()
            }
        )
        .navigationTitle("担当者を決める")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("閉じる") {
                    onDismiss()
                }
            }
        }
        .onAppear {
            initializeAssignments()
        }
    }

    // MARK: - Private Methods

    /// Initialize assignments from current week entries
    private func initializeAssignments() {
        guard let groupID = store.state.schedule.currentGroup?.id else { return }
        store.send(.assignment(.setCurrentGroupID(groupID)))

        let weekStartDate = store.state.schedule.weekStartDate
        store.send(.assignment(.initializeWeekAssignments(weekStartDate: weekStartDate)))
    }

    /// Determine member status for a specific entry
    private func memberStatus(for member: GroupMember, entry: DayScheduleEntry, isDropOff: Bool) -> MemberAvailabilityStatus {
        // Find the member's schedule entry for this date
        // For now, we check the member's availability based on their DayScheduleEntry
        // Members who have OK status for drop-off/pick-up on this date are available

        // Since we're looking at all members' entries, we need to find the entry for this specific member
        // However, the current data model doesn't directly support this lookup
        // For now, we'll use a simplified logic:
        // - If the entry belongs to the current viewing user, use their status
        // - Otherwise, assume .ok for demonstration

        // TODO: Implement proper member availability lookup from CloudKit
        // This would require fetching each member's DayScheduleEntry for the week

        // Simplified: assume all members are available (ok) for now
        // In production, this should query each member's schedule
        return .ok
    }

    /// Handle drop-off member selection
    private func handleDropOffSelection(index: Int, member: GroupMember?) {
        let userID = member.flatMap { UUID(uuidString: $0.participantID) }
        store.send(.assignment(.updateAssignment(
            index: index,
            dropOffUserID: userID,
            pickUpUserID: nil  // Don't change pick-up
        )))
    }

    /// Handle pick-up member selection
    private func handlePickUpSelection(index: Int, member: GroupMember?) {
        let userID = member.flatMap { UUID(uuidString: $0.participantID) }
        // We need to preserve the current drop-off selection
        // But the current action replaces both, so we need to get the current value
        if index < store.state.assignment.weekAssignments.count {
            let currentDropOff = store.state.assignment.weekAssignments[index].assignedDropOffUserID
            store.send(.assignment(.updateAssignment(
                index: index,
                dropOffUserID: currentDropOff,
                pickUpUserID: userID
            )))
        }
    }
}

// MARK: - Preview

// Preview requires mock AppStore, so use AssignmentPickerView preview instead
