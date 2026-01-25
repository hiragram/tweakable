import Prefire
import SwiftUI

// MARK: - JoinRequestListView

/// A view for displaying and managing pending join requests
struct JoinRequestListView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case closeButton
        case rejectButton(participantID: String)
        case approveButton(participantID: String)

        public var rawIdentifier: String {
            switch self {
            case .closeButton:
                return "joinRequestList_button_close"
            case .rejectButton(let participantID):
                return "joinRequestList_button_reject_\(participantID)"
            case .approveButton(let participantID):
                return "joinRequestList_button_approve_\(participantID)"
            }
        }
    }

    // MARK: - Properties

    /// List of pending join requests
    let requests: [JoinRequest]

    /// Currently processing request ID (participantID)
    let processingRequestID: String?

    /// Error message if any
    let errorMessage: String?

    /// Callback when approve button is tapped
    let onApprove: (JoinRequest) -> Void

    /// Callback when reject button is tapped
    let onReject: (JoinRequest) -> Void

    /// Callback when dismiss is requested
    let onDismiss: () -> Void

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                if requests.isEmpty {
                    emptyStateView
                } else {
                    requestListView
                }
            }
            .navigationTitle(String(localized: "join_request_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common_close", bundle: .app)) {
                        onDismiss()
                    }
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier(AccessibilityID.closeButton)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: theme.spacing.lg) {
            ZStack {
                Circle()
                    .fill(theme.colors.backgroundSecondary.color)
                    .frame(width: 100, height: 100)

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(theme.colors.textTertiary.color)
            }

            VStack(spacing: theme.spacing.xs) {
                Text("join_request_empty_title", bundle: .app)
                    .font(theme.typography.headlineMedium.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text("join_request_empty_description", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Request List

    private var requestListView: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.md) {
                ForEach(requests) { request in
                    requestCard(request)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.lg)
        }
    }

    // MARK: - Request Card

    private func requestCard(_ request: JoinRequest) -> some View {
        let isProcessing = processingRequestID == request.participantID

        return VStack(spacing: theme.spacing.md) {
            // User info
            HStack(spacing: theme.spacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.colors.primaryBrand.color.opacity(0.2),
                                    theme.colors.secondaryBrand.color.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Text(String(request.userName.prefix(1)))
                        .font(theme.typography.headlineMedium.font)
                        .foregroundColor(theme.colors.primaryBrand.color)
                }

                Text(request.userName)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Spacer()

                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                }
            }

            // Action buttons
            if !isProcessing {
                HStack(spacing: theme.spacing.sm) {
                    // Reject button
                    Button {
                        onReject(request)
                    } label: {
                        HStack(spacing: theme.spacing.xxs) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                            Text("join_request_reject", bundle: .app)
                                .font(theme.typography.buttonMedium.font)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle(theme: theme))
                    .accessibilityIdentifier(AccessibilityID.rejectButton(participantID: request.participantID))

                    // Approve button
                    Button {
                        onApprove(request)
                    } label: {
                        HStack(spacing: theme.spacing.xxs) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                            Text("join_request_approve", bundle: .app)
                                .font(theme.typography.buttonMedium.font)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(theme: theme))
                    .accessibilityIdentifier(AccessibilityID.approveButton(participantID: request.participantID))
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.backgroundSecondary.color)
        )
        .opacity(isProcessing ? 0.7 : 1.0)
    }

}

// MARK: - Previews

#Preview("JoinRequestListView_Okumuka - Empty") {
    JoinRequestListView_Okumuka(
        requests: [],
        processingRequestID: nil,
        errorMessage: nil,
        onApprove: { _ in },
        onReject: { _ in },
        onDismiss: {}
    )
}

#Preview("JoinRequestListView_Okumuka - With Requests") {
    JoinRequestListView_Okumuka(
        requests: [
            JoinRequest(
                participantID: "participant-1",
                userName: "田中太郎"
            ),
            JoinRequest(
                participantID: "participant-2",
                userName: "佐藤花子"
            ),
            JoinRequest(
                participantID: "participant-3",
                userName: "鈴木次郎"
            )
        ],
        processingRequestID: nil,
        errorMessage: nil,
        onApprove: { _ in },
        onReject: { _ in },
        onDismiss: {}
    )
}

#Preview("JoinRequestListView_Okumuka - Processing") {
    let processingID = "participant-processing"
    return JoinRequestListView_Okumuka(
        requests: [
            JoinRequest(
                participantID: processingID,
                userName: "田中太郎"
            ),
            JoinRequest(
                participantID: "participant-2",
                userName: "佐藤花子"
            )
        ],
        processingRequestID: processingID,
        errorMessage: nil,
        onApprove: { _ in },
        onReject: { _ in },
        onDismiss: {}
    )
}

