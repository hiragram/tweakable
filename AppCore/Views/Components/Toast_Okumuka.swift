import Prefire
import SwiftUI

/// 成功時のトースト表示
struct SuccessToast_Okumuka: View {
    let message: String
    private let theme = DesignSystem.default

    init(message: String = String(localized: "toast_saved", bundle: .app)) {
        self.message = message
    }

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .medium))

            Text(message)
                .font(theme.typography.bodyMedium.font)
        }
        .foregroundColor(.white)
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.sm)
        .background(
            Capsule()
                .fill(theme.colors.success.color)
                .shadow(theme.shadow.md)
        )
    }
}

#Preview("SuccessToast_Okumuka") {
    VStack {
        SuccessToast_Okumuka()
        SuccessToast_Okumuka(message: String(localized: "toast_sent", bundle: .app))
    }
}

