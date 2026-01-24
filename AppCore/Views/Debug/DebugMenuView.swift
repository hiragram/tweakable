//
//  DebugMenuView.swift
//  AppCore
//
//  Created by Claude on 2026/01/14.
//

import SwiftUI

/// デバッグメニュー画面
/// 開発時の設定変更（Supabase接続先切り替えなど）を行う
struct DebugMenuView: View {
    // MARK: - Properties

    let currentEnvironment: SupabaseEnvironment
    let onEnvironmentChanged: (SupabaseEnvironment) -> Void
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
                        supabaseEnvironmentSection
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.lg)
                }
            }
            .navigationTitle(Text("debug_menu_title", bundle: .app))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Text("common_done", bundle: .app)
                    }
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier("debugMenu_button_done")
                }
            }
        }
    }

    // MARK: - Sections

    private var supabaseEnvironmentSection: some View {
        SettingsSection(
            header: "debug_supabase_section_header",
            footer: "debug_supabase_section_footer"
        ) {
            ForEach(SupabaseEnvironment.allCases) { environment in
                Button {
                    onEnvironmentChanged(environment)
                } label: {
                    environmentRow(environment)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("debugMenu_button_environment_\(environment.rawValue)")

                if environment != SupabaseEnvironment.allCases.last {
                    SettingsDivider()
                }
            }
        }
    }

    // MARK: - Components

    private func environmentRow(_ environment: SupabaseEnvironment) -> some View {
        HStack(spacing: theme.spacing.sm) {
            // Icon
            Image(systemName: environment == .local ? "laptopcomputer" : "cloud")
                .font(.system(size: 24))
                .foregroundColor(theme.colors.primaryBrand.color)
                .frame(width: 32, alignment: .center)

            // Text
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(environment.displayName)
                    .font(theme.typography.bodyLarge.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                Text(environment.description)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textSecondary.color)
                    .lineLimit(1)
            }

            Spacer()

            // Checkmark
            if currentEnvironment == environment {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(theme.colors.success.color)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview("DebugMenuView - Local") {
    DebugMenuView(
        currentEnvironment: .local,
        onEnvironmentChanged: { _ in },
        onDismiss: {}
    )
    .prefireEnabled()
}

#Preview("DebugMenuView - Production") {
    DebugMenuView(
        currentEnvironment: .production,
        onEnvironmentChanged: { _ in },
        onDismiss: {}
    )
    .prefireEnabled()
}
