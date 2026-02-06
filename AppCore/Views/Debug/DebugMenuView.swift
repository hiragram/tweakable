#if DEBUG
import SwiftUI
import TipKit

/// デバッグメニュービュー
/// RevenueCatのStore切り替え、ユーザーリセット、データ全削除を提供
struct DebugMenuView: View {
    // MARK: - Properties

    let store: AppStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - Local State

    @State private var showSwitchStoreAlert = false
    @State private var showResetUserAlert = false
    @State private var showDeleteDataAlert = false
    @State private var showTipResetAlert = false
    @State private var tipResetCompleted = false

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Computed Properties

    private var currentStoreName: String {
        store.state.debug.currentStore == .testStore
            ? String(localized: "debug_menu_test_store", bundle: .app)
            : String(localized: "debug_menu_app_store", bundle: .app)
    }

    private var isTestStore: Bool {
        store.state.debug.currentStore == .testStore
    }

    private var isProcessing: Bool {
        store.state.debug.isProcessing
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    // Restart required banner
                    if store.state.debug.requiresRestart {
                        restartRequiredBanner
                    }

                    // RevenueCat Section
                    revenueCatSection

                    // Data Section
                    dataSection

                    // TipKit Section
                    tipKitSection
                }
                .padding(theme.spacing.md)
            }
            .background(theme.colors.backgroundPrimary.color)
            .navigationTitle(Text("debug_menu_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(theme.colors.textSecondary.color)
                    }
                    .accessibilityIdentifier("debugMenu_button_close")
                }
            }
            .alert(
                Text("debug_menu_switch_store_alert_title", bundle: .app),
                isPresented: $showSwitchStoreAlert
            ) {
                Button(String(localized: "cancel", bundle: .app), role: .cancel) {}
                Button(String(localized: "debug_menu_switch_store_alert_confirm", bundle: .app)) {
                    store.send(.debug(.switchStore(useTestStore: !isTestStore)))
                }
            } message: {
                Text("debug_menu_restart_required", bundle: .app)
            }
            .alert(
                Text("debug_menu_reset_user_alert_title", bundle: .app),
                isPresented: $showResetUserAlert
            ) {
                Button(String(localized: "cancel", bundle: .app), role: .cancel) {}
                Button(String(localized: "debug_menu_reset_user_alert_confirm", bundle: .app), role: .destructive) {
                    store.send(.debug(.resetUser))
                }
            } message: {
                Text("debug_menu_reset_user_alert_message", bundle: .app)
            }
            .alert(
                Text("debug_menu_delete_all_data_alert_title", bundle: .app),
                isPresented: $showDeleteDataAlert
            ) {
                Button(String(localized: "cancel", bundle: .app), role: .cancel) {}
                Button(String(localized: "debug_menu_delete_all_data_alert_confirm", bundle: .app), role: .destructive) {
                    store.send(.debug(.deleteAllData))
                }
            } message: {
                Text("debug_menu_delete_all_data_alert_message", bundle: .app)
            }
            .alert(
                Text("debug_menu_error_title", bundle: .app),
                isPresented: .constant(store.state.debug.errorMessage != nil)
            ) {
                Button(String(localized: "ok", bundle: .app)) {
                    store.send(.debug(.clearError))
                }
            } message: {
                if let error = store.state.debug.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - Restart Required Banner

    private var restartRequiredBanner: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text("debug_menu_restart_required", bundle: .app)
                .font(theme.typography.bodyMedium.font)
                .foregroundColor(theme.colors.textPrimary.color)

            Spacer()
        }
        .padding(theme.spacing.md)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
    }

    // MARK: - RevenueCat Section

    private var revenueCatSection: some View {
        SettingsSection(header: "debug_menu_revenuecat_section") {
            // Current Store
            SettingsRow(
                icon: "storefront",
                title: "debug_menu_current_store",
                subtitle: currentStoreName,
                showChevron: false,
                action: {}
            )

            SettingsDivider()

            // Switch Store
            SettingsRow(
                icon: "arrow.triangle.2.circlepath",
                title: isTestStore
                    ? LocalizedStringKey("debug_menu_switch_to_app_store")
                    : LocalizedStringKey("debug_menu_switch_to_test_store"),
                isLoading: isProcessing,
                accessibilityIdentifier: "debugMenu_button_switchStore",
                action: {
                    showSwitchStoreAlert = true
                }
            )

            SettingsDivider()

            // Reset User
            SettingsRow(
                icon: "person.crop.circle.badge.xmark",
                title: "debug_menu_reset_user",
                isLoading: isProcessing,
                accessibilityIdentifier: "debugMenu_button_resetUser",
                action: {
                    showResetUserAlert = true
                }
            )
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        SettingsSection(
            header: "debug_menu_data_section",
            footer: "debug_menu_delete_all_data_footer"
        ) {
            SettingsRow(
                icon: "trash",
                title: "debug_menu_delete_all_data",
                isDestructive: true,
                isLoading: isProcessing,
                accessibilityIdentifier: "debugMenu_button_deleteAllData",
                action: {
                    showDeleteDataAlert = true
                }
            )
        }
    }

    // MARK: - TipKit Section

    private var tipKitSection: some View {
        SettingsSection(
            header: "debug_menu_tipkit_section",
            footer: "debug_menu_tipkit_reset_footer"
        ) {
            SettingsRow(
                icon: "lightbulb",
                title: "debug_menu_tipkit_reset",
                isLoading: false,
                accessibilityIdentifier: "debugMenu_button_resetTips",
                action: {
                    showTipResetAlert = true
                }
            )
        }
        .alert(
            Text("debug_menu_tipkit_reset_alert_title", bundle: .app),
            isPresented: $showTipResetAlert
        ) {
            Button(String(localized: "cancel", bundle: .app), role: .cancel) {}
            Button(String(localized: "debug_menu_tipkit_reset_alert_confirm", bundle: .app)) {
                Task {
                    try? Tips.resetDatastore()
                    tipResetCompleted = true
                }
            }
        } message: {
            Text("debug_menu_tipkit_reset_alert_message", bundle: .app)
        }
        .alert(
            Text("debug_menu_tipkit_reset_complete_title", bundle: .app),
            isPresented: $tipResetCompleted
        ) {
            Button(String(localized: "ok", bundle: .app)) {}
        } message: {
            Text("debug_menu_tipkit_reset_complete_message", bundle: .app)
        }
    }
}

// MARK: - Previews

#Preview("DebugMenuView") {
    DebugMenuView(store: AppStore())
}
#endif
