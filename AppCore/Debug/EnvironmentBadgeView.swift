//
//  EnvironmentBadgeView.swift
//  AppCore
//
//  Created by Claude on 2026/01/14.
//

import Prefire
import SwiftUI

/// デバッグビルド時に接続先環境を表示するバッジ
struct EnvironmentBadgeView: View {
    let environment: SupabaseEnvironment

    private var backgroundColor: Color {
        switch environment {
        case .production:
            return Color(hex: "D32F2F") // 赤
        case .local:
            return Color(hex: "388E3C") // 緑
        }
    }

    private var label: String {
        switch environment {
        case .production:
            return "PROD"
        case .local:
            return "LOCAL"
        }
    }

    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview("EnvironmentBadgeView-Production") {
    EnvironmentBadgeView(environment: .production)
        .prefireEnabled()
}

#Preview("EnvironmentBadgeView-Local") {
    EnvironmentBadgeView(environment: .local)
        .prefireEnabled()
}
