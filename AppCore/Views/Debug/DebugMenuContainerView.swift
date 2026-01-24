//
//  DebugMenuContainerView.swift
//  AppCore
//
//  Created by Claude on 2026/01/14.
//

import SwiftUI

/// デバッグメニューのコンテナビュー
/// 状態管理とアクション処理を担当
public struct DebugMenuContainerView: View {
    // MARK: - Properties

    let onDismiss: () -> Void

    // MARK: - State

    @State private var currentEnvironment: SupabaseEnvironment

    // MARK: - Initializer

    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self._currentEnvironment = State(initialValue: SupabaseEnvironment.current)
    }

    // MARK: - Body

    public var body: some View {
        DebugMenuView(
            currentEnvironment: currentEnvironment,
            onEnvironmentChanged: { newEnvironment in
                currentEnvironment = newEnvironment
                SupabaseEnvironment.current = newEnvironment
            },
            onDismiss: onDismiss
        )
    }
}

// MARK: - Previews

#Preview("DebugMenuContainerView") {
    DebugMenuContainerView(onDismiss: {})
}
