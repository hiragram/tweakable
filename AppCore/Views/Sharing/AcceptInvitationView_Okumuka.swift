import Prefire
import SwiftUI

// MARK: - AcceptInvitationView

/// A view displayed when user taps a CloudKit sharing invitation link
struct AcceptInvitationView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case cancelButton
        case joinButton
        case continueButton
        case retryButton

        public var rawIdentifier: String {
            switch self {
            case .cancelButton:
                return "acceptInvitation_button_cancel"
            case .joinButton:
                return "acceptInvitation_button_join"
            case .continueButton:
                return "acceptInvitation_button_continue"
            case .retryButton:
                return "acceptInvitation_button_retry"
            }
        }
    }

    // MARK: - Properties

    /// Current state of invitation acceptance
    let state: AcceptInvitationState

    /// Information about the invitation
    let invitationInfo: InvitationInfo

    /// Callback when "Join" button is tapped
    let onAccept: () -> Void

    /// Callback when "Cancel" is tapped
    let onCancel: () -> Void

    /// Callback when "Continue" is tapped after successful join
    let onContinue: () -> Void

    /// Callback when retry is requested
    let onRetry: () -> Void

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.xl) {
                        Spacer()
                            .frame(height: theme.spacing.lg)

                        headerSection

                        contentSection

                        Spacer()
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.xl)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(String(localized: "accept_invitation_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if state == .pending || state != .success {
                        Button(String(localized: "common_cancel", bundle: .app)) {
                            onCancel()
                        }
                        .foregroundColor(theme.colors.primaryBrand.color)
                        .accessibilityIdentifier(AccessibilityID.cancelButton)
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: theme.spacing.md) {
            // Icon with gradient background
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
                    .frame(width: 100, height: 100)

                iconForState
            }

            // Title and description
            VStack(spacing: theme.spacing.xs) {
                titleForState

                descriptionForState
            }
        }
    }

    @ViewBuilder
    private var iconForState: some View {
        switch state {
        case .idle:
            EmptyView()

        case .pending:
            Image(systemName: "envelope.open.badge.clock")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.primaryBrand.color, theme.colors.secondaryBrand.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

        case .accepting:
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.primaryBrand.color, theme.colors.secondaryBrand.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.rotate, options: .repeating)

        case .success:
            Image(systemName: "person.2.badge.gearshape.fill")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.success.color, theme.colors.primaryBrand.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.error.color, theme.colors.warning.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    @ViewBuilder
    private var titleForState: some View {
        switch state {
        case .idle:
            EmptyView()

        case .pending:
            Text("accept_invitation_header", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.textPrimary.color)

        case .accepting:
            Text("accept_invitation_processing", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.textPrimary.color)

        case .success:
            Text("accept_invitation_success", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.success.color)

        case .error:
            Text("accept_invitation_error", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.error.color)
        }
    }

    @ViewBuilder
    private var descriptionForState: some View {
        switch state {
        case .idle:
            EmptyView()

        case .pending:
            Text("accept_invitation_pending_description_inviter_only \(invitationInfo.inviterName)", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

        case .accepting:
            Text("accept_invitation_accepting_description_generic", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

        case .success:
            Text("accept_invitation_success_description_generic", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

        case .error(let message):
            Text(message)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        switch state {
        case .idle:
            EmptyView()
        case .pending:
            pendingContent
        case .accepting:
            acceptingContent
        case .success:
            successContent
        case .error:
            errorContent
        }
    }

    // MARK: - Pending Content

    private var pendingContent: some View {
        VStack(spacing: theme.spacing.lg) {
            // Invitation details card
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.info.color)

                    Text("accept_invitation_details", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    detailRow(icon: "person.fill", label: String(localized: "accept_invitation_inviter", bundle: .app), value: invitationInfo.inviterName)
                    if let groupName = invitationInfo.groupName {
                        detailRow(icon: "house.fill", label: String(localized: "accept_invitation_group", bundle: .app), value: groupName)
                    }
                }
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )

            // What happens card
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.warning.color)

                    Text("accept_invitation_benefits", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    featureRow(icon: "calendar", text: String(localized: "accept_invitation_share_schedule", bundle: .app))
                    featureRow(icon: "bell.fill", text: String(localized: "accept_invitation_receive_notifications", bundle: .app))
                    featureRow(icon: "person.2.fill", text: String(localized: "accept_invitation_coordinate", bundle: .app))
                }
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )

            // Accept button
            Button {
                onAccept()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))

                    Text("accept_invitation_join", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.joinButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(theme.colors.primaryBrand.color)
                .frame(width: 20)

            Text(label)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textTertiary.color)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(theme.typography.bodyMedium.font)
                .fontWeight(.medium)
                .foregroundColor(theme.colors.textPrimary.color)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(theme.colors.success.color)
                .frame(width: 20)

            Text(text)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
        }
    }

    // MARK: - Accepting Content

    private var acceptingContent: some View {
        VStack(spacing: theme.spacing.lg) {
            // Loading card
            VStack(spacing: theme.spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                    .scaleEffect(1.5)

                Text("accept_invitation_processing_message", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, theme.spacing.xxl)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Success Content

    private var successContent: some View {
        VStack(spacing: theme.spacing.lg) {
            // Success indicator
            ZStack {
                Circle()
                    .fill(theme.colors.success.color.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(theme.colors.success.color)
            }

            // Success message card
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.colors.warning.color)

                    Text("accept_invitation_welcome", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                Text("accept_invitation_welcome_message_generic", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .lineSpacing(4)
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.success.color.opacity(0.08))
            )

            // Continue button
            Button {
                onContinue()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18, weight: .medium))

                    Text("accept_invitation_view_schedule", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.continueButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Error Content

    private var errorContent: some View {
        VStack(spacing: theme.spacing.lg) {
            // Error indicator
            ZStack {
                Circle()
                    .fill(theme.colors.error.color.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(theme.colors.error.color)
            }

            // Error message card
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.colors.error.color)

                    Text("accept_invitation_error_occurred", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                Text("accept_invitation_retry_message", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.error.color.opacity(0.08))
            )

            // Retry button
            Button {
                onRetry()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))

                    Text("common_retry", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.retryButton)
        }
        .padding(.horizontal, theme.spacing.xs)
    }
}

// MARK: - Previews

#Preview("AcceptInvitationView_Okumuka - Pending") {
    AcceptInvitationView_Okumuka(
        state: .pending,
        invitationInfo: InvitationInfo(inviterName: "田中", groupName: "山田家"),
        onAccept: {},
        onCancel: {},
        onContinue: {},
        onRetry: {}
    )
}

#Preview("AcceptInvitationView_Okumuka - Accepting") {
    AcceptInvitationView_Okumuka(
        state: .accepting,
        invitationInfo: InvitationInfo(inviterName: "田中", groupName: "山田家"),
        onAccept: {},
        onCancel: {},
        onContinue: {},
        onRetry: {}
    )
}

#Preview("AcceptInvitationView_Okumuka - Success") {
    AcceptInvitationView_Okumuka(
        state: .success,
        invitationInfo: InvitationInfo(inviterName: "田中", groupName: "山田家"),
        onAccept: {},
        onCancel: {},
        onContinue: {},
        onRetry: {}
    )
}

#Preview("AcceptInvitationView_Okumuka - Error") {
    AcceptInvitationView_Okumuka(
        state: .error(message: "iCloud接続エラーが発生しました。\nネットワーク設定を確認してください。"),
        invitationInfo: InvitationInfo(inviterName: "田中", groupName: "山田家"),
        onAccept: {},
        onCancel: {},
        onContinue: {},
        onRetry: {}
    )
}

