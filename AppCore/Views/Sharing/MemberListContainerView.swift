import SwiftUI

// MARK: - MemberListContainerView

/// Container view that connects MemberListView to AppStore
struct MemberListContainerView: View {
    // MARK: - Properties

    @Bindable var store: AppStore

    /// Callback when the view is dismissed
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        MemberListView(
            members: store.state.sharing.members,
            isLoading: store.state.sharing.isLoadingMembers,
            errorMessage: store.state.sharing.sharingError,
            onDismiss: onDismiss
        )
        .onAppear {
            store.send(AppAction.sharing(.loadMembers))
        }
    }
}
