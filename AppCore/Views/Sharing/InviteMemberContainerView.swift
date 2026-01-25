import SwiftUI

/// Container view that connects AppStore to InviteMemberView
struct InviteMemberContainerView: View {
    // MARK: - Properties

    let store: AppStore
    let onDismiss: () -> Void

    // MARK: - Local State

    @State private var showShareSheet = false
    @State private var shareURL: URL?

    // MARK: - Computed Properties

    private var groupName: String {
        store.state.schedule.currentGroup?.name ?? ""
    }

    // MARK: - Body

    var body: some View {
        InviteMemberView_Okumuka(
            invitationState: store.state.sharing.invitationState,
            groupName: groupName,
            onShare: { url in
                shareURL = url
                showShareSheet = true
            },
            onDismiss: {
                store.send(.sharing(.resetInvitation))
                onDismiss()
            },
            onRetry: {
                store.send(.sharing(.clearError))
                store.send(.sharing(.startCreatingShare))
            }
        )
        .task {
            // 画面表示時に自動でShare作成を開始
            if store.state.sharing.invitationState == .idle {
                store.send(.sharing(.startCreatingShare))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(items: [url])
            }
        }
    }
}

// MARK: - ShareSheet

/// UIActivityViewController wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("InviteMemberContainer") {
    Text("Preview requires AppStore setup")
}
