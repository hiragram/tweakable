import Prefire
import SwiftUI

// MARK: - MemberListView

/// A view for displaying group members
struct MemberListView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case closeButton

        public var rawIdentifier: String {
            switch self {
            case .closeButton:
                return "memberList_button_close"
            }
        }
    }

    // MARK: - Properties

    /// List of group members
    let members: [GroupMember]

    /// Whether members are being loaded
    let isLoading: Bool

    /// Error message if any
    let errorMessage: String?

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

                if isLoading {
                    loadingView
                } else if members.isEmpty {
                    emptyStateView
                } else {
                    memberListView
                }
            }
            .navigationTitle(String(localized: "member_list_title", bundle: .app))
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

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: theme.spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primaryBrand.color))
            Text("member_list_loading", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: theme.spacing.lg) {
            ZStack {
                Circle()
                    .fill(theme.colors.backgroundSecondary.color)
                    .frame(width: 100, height: 100)

                Image(systemName: "person.2.slash")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(theme.colors.textTertiary.color)
            }

            VStack(spacing: theme.spacing.xs) {
                Text("member_list_empty_title", bundle: .app)
                    .font(theme.typography.headlineMedium.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text("member_list_empty_description", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Member List

    private var memberListView: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.md) {
                ForEach(members) { member in
                    memberCard(member)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.lg)
        }
    }

    // MARK: - Member Card

    private func memberCard(_ member: GroupMember) -> some View {
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

                Text(String(member.displayName.prefix(1)))
                    .font(theme.typography.headlineMedium.font)
                    .foregroundColor(theme.colors.primaryBrand.color)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(member.displayName)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                if member.isOwner {
                    Text("member_list_owner_badge", bundle: .app)
                        .font(theme.typography.captionLarge.font)
                        .foregroundColor(theme.colors.primaryBrand.color)
                }
            }

            Spacer()

            if member.isOwner {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.primaryBrand.color)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                .fill(theme.colors.backgroundSecondary.color)
        )
    }
}

// MARK: - Previews

#Preview("MemberListView_Okumuka - Empty") {
    MemberListView_Okumuka(
        members: [],
        isLoading: false,
        errorMessage: nil,
        onDismiss: {}
    )
}

#Preview("MemberListView_Okumuka - Loading") {
    MemberListView_Okumuka(
        members: [],
        isLoading: true,
        errorMessage: nil,
        onDismiss: {}
    )
}

#Preview("MemberListView_Okumuka - With Members") {
    MemberListView_Okumuka(
        members: [
            GroupMember(
                participantID: "owner-id",
                displayName: "山田太郎",
                isOwner: true
            ),
            GroupMember(
                participantID: "member-1",
                displayName: "田中花子",
                isOwner: false
            ),
            GroupMember(
                participantID: "member-2",
                displayName: "佐藤次郎",
                isOwner: false
            )
        ],
        isLoading: false,
        errorMessage: nil,
        onDismiss: {}
    )
}

