import Prefire
import SwiftUI

/// ネットワーク切断時に表示するバナー
struct NetworkStatusBanner: View {
    let theme: DesignSystem

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 14, weight: .medium))

            Text("network_offline", bundle: .app)
                .font(theme.typography.captionLarge.font)
        }
        .foregroundColor(.white)
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .frame(maxWidth: .infinity)
        .background(theme.colors.warning.color)
    }
}

#Preview("NetworkStatusBanner") {
    VStack {
        NetworkStatusBanner(theme: DesignSystem.default)
        Spacer()
    }
    .prefireEnabled()
}

