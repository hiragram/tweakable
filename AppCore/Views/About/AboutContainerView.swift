import SwiftUI

/// AboutViewのコンテナビュー
/// アプリ情報の取得とライセンス画面への遷移を担当
struct AboutContainerView: View {
    let onDismiss: () -> Void

    // MARK: - State

    @State private var installDate: Date?

    // MARK: - Dependencies

    private let appInfoService: AppInfoServiceProtocol

    // MARK: - Initialization

    init(
        appInfoService: AppInfoServiceProtocol = AppInfoService.shared,
        onDismiss: @escaping () -> Void
    ) {
        self.appInfoService = appInfoService
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    var body: some View {
        AboutView(
            appVersion: appInfoService.appVersion,
            buildNumber: appInfoService.buildNumber,
            installDate: installDate,
            onLicenseTapped: openLicenseSettings,
            onDismiss: onDismiss
        )
        .task {
            installDate = await appInfoService.getOriginalPurchaseDate()
        }
    }

    // MARK: - Actions

    /// 設定アプリのライセンス画面を開く
    private func openLicenseSettings() {
        // 設定アプリ内のこのアプリの設定画面を開く
        // Settings.bundle内のライセンス情報が表示される
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }
}

// MARK: - Preview

#Preview("About Container") {
    AboutContainerView(onDismiss: {})
}
