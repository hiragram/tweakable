import Prefire
import SwiftUI

/// 「このアプリについて」画面
/// バージョン情報、インストール日時、ライセンス情報へのリンクを表示
struct AboutView_Okumuka: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case doneButton
        case licenseButton

        public var rawIdentifier: String {
            switch self {
            case .doneButton:
                return "about_button_done"
            case .licenseButton:
                return "about_button_license"
            }
        }
    }

    // MARK: - Parameters

    let appVersion: String
    let buildNumber: String
    let installDate: Date?
    let onLicenseTapped: () -> Void
    let onDismiss: () -> Void

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.lg) {
                        appInfoSection

                        licenseSection

                        Spacer()
                            .frame(height: theme.spacing.xl)
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.top, theme.spacing.md)
                }
            }
            .navigationTitle(String(localized: "about_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common_done", bundle: .app)) {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier(AccessibilityID.doneButton)
                }
            }
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("about_app_info", bundle: .app)
                .font(theme.typography.headlineSmall.font)
                .foregroundColor(theme.colors.textSecondary.color)

            VStack(spacing: 0) {
                infoRow(
                    icon: "app.badge",
                    title: String(localized: "about_version", bundle: .app),
                    value: appVersion
                )

                Divider()
                    .background(theme.colors.separator.color)
                    .padding(.leading, theme.spacing.md)

                infoRow(
                    icon: "hammer",
                    title: String(localized: "about_build", bundle: .app),
                    value: buildNumber
                )

                Divider()
                    .background(theme.colors.separator.color)
                    .padding(.leading, theme.spacing.md)

                infoRow(
                    icon: "calendar",
                    title: String(localized: "about_install_date", bundle: .app),
                    value: formattedInstallDate
                )
            }
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(theme.colors.primaryBrand.color)
                .frame(width: 28)

            Text(title)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Spacer()

            Text(value)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textSecondary.color)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
    }

    private var formattedInstallDate: String {
        guard let date = installDate else {
            return String(localized: "about_install_date_unknown", bundle: .app)
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - License Section

    private var licenseSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("about_legal", bundle: .app)
                .font(theme.typography.headlineSmall.font)
                .foregroundColor(theme.colors.textSecondary.color)

            Button {
                onLicenseTapped()
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                        .foregroundColor(theme.colors.primaryBrand.color)
                        .frame(width: 28)

                    Text("about_license", bundle: .app)
                        .font(theme.typography.bodyMedium.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    Spacer()

                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textTertiary.color)
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
            }
            .background(theme.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
            .accessibilityIdentifier(AccessibilityID.licenseButton)

            Text("about_license_description", bundle: .app)
                .font(theme.typography.captionLarge.font)
                .foregroundColor(theme.colors.textTertiary.color)
        }
    }
}

// MARK: - Preview

#Preview("AboutView_Okumuka") {
    // 2024年1月1日 12:00:00 JST（スナップショットテスト用の固定日時）
    AboutView_Okumuka(
        appVersion: "1.0.0",
        buildNumber: "42",
        installDate: Date(timeIntervalSince1970: 1704085200),
        onLicenseTapped: {},
        onDismiss: {}
    )
}

#Preview("AboutView_Okumuka - NoInstallDate") {
    AboutView_Okumuka(
        appVersion: "1.0.0",
        buildNumber: "42",
        installDate: nil,
        onLicenseTapped: {},
        onDismiss: {}
    )
}

