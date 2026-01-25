import Prefire
import SwiftUI

/// A view for creating a new UserGroup (family group)
/// This is a pure View that receives parameters and callbacks
struct CreateGroupView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case cancelButton
        case groupNameTextField
        case clearGroupNameButton
        case createButton
        case invitationUrlTextField
        case joinWithUrlButton
        case alertOkButton

        public var rawIdentifier: String {
            switch self {
            case .cancelButton:
                return "createGroup_button_cancel"
            case .groupNameTextField:
                return "createGroup_textField_groupName"
            case .clearGroupNameButton:
                return "createGroup_button_clearGroupName"
            case .createButton:
                return "createGroup_button_create"
            case .invitationUrlTextField:
                return "createGroup_textField_invitationUrl"
            case .joinWithUrlButton:
                return "createGroup_button_joinWithUrl"
            case .alertOkButton:
                return "createGroup_button_alertOk"
            }
        }
    }

    // MARK: - Properties

    /// The current group name input
    let groupName: String
    /// Whether a validation error should be shown
    let showsValidationError: Bool
    /// Whether the group is currently being created
    let isCreating: Bool

    /// Callback when group name changes
    let onGroupNameChanged: (String) -> Void
    /// Callback when cancel button is tapped
    let onCancel: () -> Void
    /// Callback when create button is tapped
    let onCreate: () -> Void
    /// Callback when invitation URL is pasted (Debug only)
    let onPasteInvitationURL: (URL) -> Void

    // MARK: - Theme

    private let theme = DesignSystem.default

    // MARK: - Computed Properties

    private var trimmedName: String {
        groupName.trimmingCharacters(in: .whitespaces)
    }

    private var isNameValid: Bool {
        !trimmedName.isEmpty
    }

    private var canCreate: Bool {
        isNameValid && !isCreating
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.xl) {
                        Spacer()
                            .frame(height: theme.spacing.xl)

                        headerSection

                        inputSection

                        Spacer()

                        createButtonSection

                        #if DEBUG
                        joinWithURLSection
                        #endif
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.xl)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(String(localized: "create_group_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common_cancel", bundle: .app)) {
                        onCancel()
                    }
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier(AccessibilityID.cancelButton)
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

                Image(systemName: "person.3.fill")
                    .font(.system(size: 40, weight: .medium))
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
                Text("create_group_header_title", bundle: .app)
                    .font(theme.typography.displaySmall.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text("create_group_header_description", bundle: .app)
                    .font(theme.typography.bodyMedium.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("create_group_name_label", bundle: .app)
                .font(theme.typography.headlineSmall.font)
                .foregroundColor(theme.colors.textSecondary.color)

            // Text field with custom styling
            HStack {
                TextField(String(localized: "create_group_name_placeholder", bundle: .app), text: Binding(
                    get: { groupName },
                    set: { onGroupNameChanged($0) }
                ))
                .font(theme.typography.bodyLarge.font)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(isCreating)
                .accessibilityIdentifier(AccessibilityID.groupNameTextField)

                if !groupName.isEmpty && !isCreating {
                    Button {
                        onGroupNameChanged("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(theme.colors.textTertiary.color)
                    }
                    .accessibilityIdentifier(AccessibilityID.clearGroupNameButton)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .stroke(
                        showsValidationError ? theme.colors.error.color : Color.clear,
                        lineWidth: 2
                    )
            )

            // Validation error or helper text
            if showsValidationError {
                HStack(spacing: theme.spacing.xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text("create_group_name_error", bundle: .app)
                        .font(theme.typography.captionLarge.font)
                }
                .foregroundColor(theme.colors.error.color)
            } else {
                Text("create_group_name_helper", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            }
        }
        .padding(.horizontal, theme.spacing.xs)
    }

    // MARK: - Create Button Section

    private var createButtonSection: some View {
        Button {
            onCreate()
        } label: {
            HStack(spacing: theme.spacing.xs) {
                if isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                }

                Text(isCreating ? String(localized: "create_group_creating", bundle: .app) : String(localized: "no_group_create", bundle: .app))
                    .font(theme.typography.buttonLarge.font)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                    .fill(
                        canCreate
                            ? theme.colors.primaryBrand.color
                            : theme.colors.primaryBrand.color.opacity(0.5)
                    )
            )
        }
        .disabled(!canCreate)
        .animation(.easeInOut(duration: 0.2), value: isCreating)
        .padding(.horizontal, theme.spacing.xs)
        .accessibilityIdentifier(AccessibilityID.createButton)
    }

    // MARK: - Join With URL Section (Debug)

    @State private var invitationURLText: String = ""
    @State private var showInvalidURLAlert: Bool = false

    private var joinWithURLSection: some View {
        VStack(spacing: theme.spacing.md) {
            // Divider with "or" text
            HStack {
                Rectangle()
                    .fill(theme.colors.separator.color)
                    .frame(height: 1)
                Text("create_group_or", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
                Rectangle()
                    .fill(theme.colors.separator.color)
                    .frame(height: 1)
            }
            .padding(.top, theme.spacing.md)

            // URL input section
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text("create_group_join_with_url", bundle: .app)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textSecondary.color)

                TextField(
                    String(localized: "create_group_url_placeholder", bundle: .app),
                    text: $invitationURLText
                )
                .font(theme.typography.bodyMedium.font)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.backgroundSecondary.color)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
                .accessibilityIdentifier(AccessibilityID.invitationUrlTextField)

                Button {
                    let trimmed = invitationURLText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let url = URL(string: trimmed), url.scheme == "https" {
                        onPasteInvitationURL(url)
                        invitationURLText = ""
                    } else {
                        showInvalidURLAlert = true
                    }
                } label: {
                    HStack(spacing: theme.spacing.xs) {
                        Image(systemName: "link")
                            .font(.system(size: 16, weight: .medium))
                        Text("create_group_join_button", bundle: .app)
                            .font(theme.typography.buttonMedium.font)
                    }
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                            .stroke(theme.colors.primaryBrand.color, lineWidth: 1.5)
                    )
                }
                .disabled(invitationURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(invitationURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                .accessibilityIdentifier(AccessibilityID.joinWithUrlButton)

                Text("create_group_join_footer", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            }
            .padding(.horizontal, theme.spacing.xs)
        }
        .alert(
            String(localized: "settings_join_group_invalid_url", bundle: .app),
            isPresented: $showInvalidURLAlert
        ) {
            Button(String(localized: "common_ok", bundle: .app), role: .cancel) {}
                .accessibilityIdentifier(AccessibilityID.alertOkButton)
        }
    }
}

// MARK: - Previews

#Preview("CreateGroupView_Okumuka - Empty") {
    CreateGroupView_Okumuka(
        groupName: "",
        showsValidationError: false,
        isCreating: false,
        onGroupNameChanged: { _ in },
        onCancel: {},
        onCreate: {},
        onPasteInvitationURL: { _ in }
    )
}

#Preview("CreateGroupView_Okumuka - Editing") {
    CreateGroupView_Okumuka(
        groupName: "山田家",
        showsValidationError: false,
        isCreating: false,
        onGroupNameChanged: { _ in },
        onCancel: {},
        onCreate: {},
        onPasteInvitationURL: { _ in }
    )
}

#Preview("CreateGroupView_Okumuka - ValidationError") {
    CreateGroupView_Okumuka(
        groupName: "",
        showsValidationError: true,
        isCreating: false,
        onGroupNameChanged: { _ in },
        onCancel: {},
        onCreate: {},
        onPasteInvitationURL: { _ in }
    )
}

#Preview("CreateGroupView_Okumuka - Loading") {
    CreateGroupView_Okumuka(
        groupName: "山田家",
        showsValidationError: false,
        isCreating: true,
        onGroupNameChanged: { _ in },
        onCancel: {},
        onCreate: {},
        onPasteInvitationURL: { _ in }
    )
}


