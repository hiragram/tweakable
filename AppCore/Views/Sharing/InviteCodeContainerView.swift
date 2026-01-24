import SwiftUI

// MARK: - InviteCodeContainerView

/// InviteCodeViewとStoreを接続するコンテナビュー
public struct InviteCodeContainerView: View {
    // MARK: - Properties

    @Bindable private var store: AppStore

    /// グループ名
    private let groupName: String

    /// 閉じるコールバック
    private let onDismiss: () -> Void

    // MARK: - Initialization

    public init(store: AppStore, groupName: String, onDismiss: @escaping () -> Void) {
        self.store = store
        self.groupName = groupName
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        InviteCodeView(
            isCreating: store.state.sharing.isCreatingInviteCode,
            generatedCode: store.state.sharing.generatedInviteCode,
            errorMessage: store.state.sharing.sharingError,
            groupName: groupName,
            onDismiss: {
                // 状態をリセットして閉じる
                store.send(.sharing(.resetInviteCodeState))
                onDismiss()
            },
            onGenerate: {
                store.send(.sharing(.startCreatingInviteCode))
            }
        )
    }
}
