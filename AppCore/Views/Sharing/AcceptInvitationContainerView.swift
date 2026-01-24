import SwiftUI

/// Container view that connects AppStore to AcceptInvitationView
struct AcceptInvitationContainerView: View {
    // MARK: - Properties

    let store: AppStore
    /// 外部から渡された招待情報（設定画面などから直接表示する場合）
    /// nilの場合はstoreから取得
    let invitationInfo: InvitationInfo?
    let onDismiss: () -> Void
    let onContinueToSchedule: () -> Void

    // MARK: - Initializers

    /// RootViewから表示する場合（storeから招待情報を取得）
    init(store: AppStore, onDismiss: @escaping () -> Void, onContinueToSchedule: @escaping () -> Void) {
        self.store = store
        self.invitationInfo = nil
        self.onDismiss = onDismiss
        self.onContinueToSchedule = onContinueToSchedule
    }

    /// 設定画面などから直接表示する場合（招待情報を外部から渡す）
    init(store: AppStore, invitationInfo: InvitationInfo, onDismiss: @escaping () -> Void, onContinueToSchedule: @escaping () -> Void) {
        self.store = store
        self.invitationInfo = invitationInfo
        self.onDismiss = onDismiss
        self.onContinueToSchedule = onContinueToSchedule
    }

    // MARK: - Computed Properties

    private var resolvedInvitationInfo: InvitationInfo {
        invitationInfo ?? store.state.sharing.pendingInvitationInfo ?? InvitationInfo(
            inviterName: "",
            groupName: ""
        )
    }

    // MARK: - Body

    var body: some View {
        AcceptInvitationView(
            state: store.state.sharing.acceptInvitationState,
            invitationInfo: resolvedInvitationInfo,
            onAccept: {
                store.send(.sharing(.startAcceptingShare))
            },
            onCancel: {
                store.send(.sharing(.resetAcceptInvitation))
                onDismiss()
            },
            onContinue: {
                store.send(.sharing(.resetAcceptInvitation))
                onContinueToSchedule()
            },
            onRetry: {
                store.send(.sharing(.clearError))
                store.send(.sharing(.startAcceptingShare))
            }
        )
    }
}

// MARK: - Preview

#Preview("AcceptInvitationContainer") {
    Text("Preview requires AppStore setup")
}
