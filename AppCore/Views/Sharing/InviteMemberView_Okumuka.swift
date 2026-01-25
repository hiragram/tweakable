import Prefire
import SwiftUI

// MARK: - InviteMemberView

/// A view for inviting members to the family group via CloudKit Sharing
struct InviteMemberView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case closeButton
        case copyUrlButton
        case shareButton
        case retryButton

        public var rawIdentifier: String {
            switch self {
            case .closeButton:
                return "inviteMember_button_close"
            case .copyUrlButton:
                return "inviteMember_button_copyUrl"
            case .shareButton:
                return "inviteMember_button_share"
            case .retryButton:
                return "inviteMember_button_retry"
            }
        }
    }

    // MARK: - Properties

    /// Current state of invitation creation
    let invitationState: InvitationState

    /// The group name to display
    let groupName: String

    /// Callback when share button is tapped with the URL
    let onShare: (URL) -> Void

    /// Callback when dismiss/close is requested
    let onDismiss: () -> Void

    /// Callback when retry is requested
    let onRetry: () -> Void

    // MARK: - Local State

    @State private var showCopiedFeedback = false

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
            .navigationTitle(String(localized: "invite_member_title", bundle: .app))
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

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.colors.primaryBrand.color, theme.colors.secondaryBrand.color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Title and description
            VStack(spacing: theme.spacing.xs) {
                Text("invite_member_header_title", bundle: .app)
                    .font(theme.typography.displaySmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text("invite_member_header_description \(groupName)", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        switch invitationState {
        case .idle, .creating:
            creatingContent
        case .success(let url):
            successContent(url: url)
        case .error(let message):
            errorContent(message: message)
        }
    }

    private func stepRow(number: Int, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Text("\(number)")
                .font(theme.typography.captionLarge.font)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(theme.colors.primaryBrand.color)
                )

            Text(text, bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
        }
    }

    // MARK: - Creating Content

    private var creatingContent: some View {
        VStack(spacing: theme.spacing.lg) {
            // Loading card
            VStack(spacing: theme.spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
                    .scaleEffect(1.5)

                Text("invite_member_creating", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
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

    private func successContent(url: URL) -> some View {
        VStack(spacing: theme.spacing.lg) {
            // URL Card
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // URL display (tap to copy)
                Button {
                    UIPasteboard.general.string = url.absoluteString
                    showCopiedFeedback = true
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        showCopiedFeedback = false
                    }
                } label: {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(url.absoluteString)
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(theme.colors.textSecondary.color)
                            .lineLimit(2)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: theme.spacing.xxs) {
                            if showCopiedFeedback {
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.colors.success.color)
                                Text("invite_member_copied", bundle: .app)
                                    .foregroundColor(theme.colors.success.color)
                            } else {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(theme.colors.textTertiary.color)
                                Text("invite_member_tap_to_copy", bundle: .app)
                                    .foregroundColor(theme.colors.textTertiary.color)
                            }
                        }
                        .font(theme.typography.captionLarge.font)
                    }
                    .padding(theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadius.xs)
                            .fill(theme.colors.backgroundTertiary.color)
                    )
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.success, trigger: showCopiedFeedback)
                .accessibilityIdentifier(AccessibilityID.copyUrlButton)
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .fill(theme.colors.backgroundSecondary.color)
            )

            // Share button
            Button {
                onShare(url)
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))

                    Text("invite_member_share", bundle: .app)
                        .font(theme.typography.buttonLarge.font)
                }
            }
            .buttonStyle(PrimaryButtonStyle(theme: theme))
            .accessibilityIdentifier(AccessibilityID.shareButton)

            // Hint text
            Text("invite_member_share_hint", bundle: .app)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textTertiary.color)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Error Content

    private func errorContent(message: String) -> some View {
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

                    Text("invite_member_error_title", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textPrimary.color)
                }

                Text(message)
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

                    Text("invite_member_retry", bundle: .app)
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

#Preview("InviteMemberView_Okumuka - Creating") {
    InviteMemberView_Okumuka(
        invitationState: .creating,
        groupName: "yamada-family",
        onShare: { _ in },
        onDismiss: {},
        onRetry: {}
    )
}

#Preview("InviteMemberView_Okumuka - Success") {
    InviteMemberView_Okumuka(
        invitationState: .success(url: URL(string: "https://www.icloud.com/share/abc123def456")!),
        groupName: "yamada-family",
        onShare: { _ in },
        onDismiss: {},
        onRetry: {}
    )
}

#Preview("InviteMemberView_Okumuka - Error") {
    InviteMemberView_Okumuka(
        invitationState: .error(message: "iCloud connection error occurred. Please check your network and try again."),
        groupName: "yamada-family",
        onShare: { _ in },
        onDismiss: {},
        onRetry: {}
    )
}

