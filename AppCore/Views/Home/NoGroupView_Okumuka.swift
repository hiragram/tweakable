import Prefire
import SwiftUI

/// View displayed when user has no group set up
/// Prompts user to create a new group
struct NoGroupView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case createGroupButton

        public var rawIdentifier: String {
            switch self {
            case .createGroupButton:
                return "noGroup_button_createGroup"
            }
        }
    }

    // MARK: - Actions

    let onCreateGroupTapped: () -> Void

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary.color
                .ignoresSafeArea()

            VStack(spacing: theme.spacing.xl) {
                Spacer()

                iconSection

                textSection

                Spacer()

                createGroupButton
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.bottom, theme.spacing.xl)
        }
    }

    // MARK: - Icon Section

    private var iconSection: some View {
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
                .frame(width: 120, height: 120)

            Image(systemName: "person.3.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.colors.primaryBrand.color, theme.colors.secondaryBrand.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(spacing: theme.spacing.sm) {
            Text("no_group_title", bundle: .app)
                .font(theme.typography.displaySmall.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Text("no_group_description", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Create Group Button

    private var createGroupButton: some View {
        Button {
            onCreateGroupTapped()
        } label: {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .medium))

                Text("no_group_create", bundle: .app)
            }
        }
        .buttonStyle(PrimaryButtonStyle(theme: theme))
        .accessibilityIdentifier(AccessibilityID.createGroupButton)
    }
}

// MARK: - Previews

#Preview("NoGroupView_Okumuka") {
    NoGroupView_Okumuka(
        onCreateGroupTapped: {}
    )
}


