import SwiftUI

// MARK: - JoinRequestListContainerView

/// Container view that connects JoinRequestListView to AppStore
struct JoinRequestListContainerView: View {
    // MARK: - Properties

    @Bindable var store: AppStore

    /// Callback when the view is dismissed
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        JoinRequestListView(
            requests: store.state.sharing.pendingJoinRequests,
            processingRequestID: store.state.sharing.processingRequestID,
            errorMessage: store.state.sharing.sharingError,
            onApprove: { request in
                store.send(AppAction.sharing(.startApprovingRequest(participantID: request.participantID)))
            },
            onReject: { request in
                store.send(AppAction.sharing(.startRejectingRequest(participantID: request.participantID)))
            },
            onDismiss: onDismiss
        )
        .onAppear {
            store.send(AppAction.sharing(.loadPendingJoinRequests))
        }
        .onChange(of: store.state.sharing.pendingJoinRequests) { oldValue, newValue in
            print("[DEBUG] JoinRequestListContainerView: pendingJoinRequests changed")
            print("[DEBUG]   oldValue: \(oldValue.count) requests")
            print("[DEBUG]   newValue: \(newValue.count) requests")
            for req in newValue {
                print("[DEBUG]   - userName: '\(req.userName)'")
            }
        }
    }
}
