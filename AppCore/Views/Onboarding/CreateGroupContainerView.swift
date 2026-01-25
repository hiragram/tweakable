import SwiftUI

/// Container view that bridges AppStore and CreateGroupView
struct CreateGroupContainerView: View {
    // MARK: - Dependencies

    let store: AppStore

    /// Callback when the user cancels group creation
    let onCancel: () -> Void

    /// Callback when group creation completes
    let onComplete: () -> Void

    /// Callback when successfully joined a group via invitation URL
    var onJoinComplete: (() -> Void)?

    // MARK: - Local State

    @State private var groupName: String = ""
    @State private var showsValidationError: Bool = false
    @State private var pendingInvitationInfo: InvitationInfo?

    // MARK: - Computed Properties

    private var isCreating: Bool {
        store.state.schedule.isCreatingGroup
    }

    private var trimmedName: String {
        groupName.trimmingCharacters(in: .whitespaces)
    }

    private var isNameValid: Bool {
        !trimmedName.isEmpty
    }

    // MARK: - Body

    var body: some View {
        CreateGroupView_Okumuka(
            groupName: groupName,
            showsValidationError: showsValidationError,
            isCreating: isCreating,
            onGroupNameChanged: handleGroupNameChanged,
            onCancel: onCancel,
            onCreate: handleCreate,
            onPasteInvitationURL: { _ in
                // バックエンドなし - 招待機能は削除
                fatalError("Invitation functionality has been removed - standalone mode")
            }
        )
        .sheet(item: $pendingInvitationInfo) { info in
            AcceptInvitationContainerView(
                store: store,
                invitationInfo: info,
                onDismiss: {
                    pendingInvitationInfo = nil
                },
                onContinueToSchedule: {
                    pendingInvitationInfo = nil
                    // 参加完了後はCreateGroup画面も閉じる
                    if let onJoinComplete {
                        onJoinComplete()
                    } else {
                        onComplete()
                    }
                }
            )
        }
        .onChange(of: store.state.schedule.currentGroup) { oldValue, newValue in
            // When group changes (created or switched), trigger completion
            if newValue != nil && oldValue?.id != newValue?.id {
                onComplete()
            }
        }
    }

    // MARK: - Actions

    private func handleGroupNameChanged(_ newName: String) {
        groupName = newName
        if showsValidationError {
            showsValidationError = false
        }
    }

    private func handleCreate() {
        // Validate input
        if !isNameValid {
            withAnimation(.easeInOut(duration: 0.2)) {
                showsValidationError = true
            }
            return
        }

        // Start creating group
        store.send(.schedule(.startCreatingGroup))
        store.send(.schedule(.createGroup(name: trimmedName)))
    }
}

// MARK: - Previews

#Preview("Container View") {
    // Note: This preview requires a mock store setup
    // For actual preview, use CreateGroupView directly
    Text("Use CreateGroupView previews for UI testing")
}
