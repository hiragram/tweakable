import SwiftUI

// MARK: - JoinWithCodeContainerView

/// JoinWithCodeViewとStoreを接続するコンテナビュー
public struct JoinWithCodeContainerView: View {
    // MARK: - Properties

    @Bindable private var store: AppStore

    /// 閉じるコールバック
    private let onDismiss: () -> Void

    // MARK: - Initialization

    public init(store: AppStore, onDismiss: @escaping () -> Void) {
        self.store = store
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        JoinWithCodeView_Okumuka(
            codeInput: Binding(
                get: { store.state.sharing.inviteCodeInput },
                set: { store.send(.sharing(.setInviteCodeInput($0))) }
            ),
            isJoining: store.state.sharing.isJoiningWithCode,
            joinedGroup: store.state.sharing.joinedSupabaseGroup,
            errorMessage: store.state.sharing.sharingError,
            onDismiss: {
                // 状態をリセットして閉じる
                store.send(.sharing(.resetInviteCodeState))
                onDismiss()
            },
            onJoin: {
                store.send(.sharing(.startJoiningWithCode))
            }
        )
    }
}
