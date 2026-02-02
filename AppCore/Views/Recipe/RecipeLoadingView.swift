import Prefire
import SwiftUI

// MARK: - RecipeLoadingView

/// レシピ読み込み中のローディング画面
/// 食材・調理器具・料理のアイコンがゆらゆら揺れながら切り替わる
struct RecipeLoadingView: View {
    private let ds = DesignSystem.default

    // アイコン切り替え用
    @State private var currentIconIndex = 0
    @State private var isAnimating = false

    // アイコン画像名のリスト
    private let iconNames = [
        "loading-icon-tomato",
        "loading-icon-carrot",
        "loading-icon-frypan",
        "loading-icon-knife",
        "loading-icon-ramen",
        "loading-icon-hotdog"
    ]

    // 進捗メッセージ
    @State private var messageIndex = 0
    private let messages: [LocalizedStringResource] = [
        .recipeLoadingMessage1,
        .recipeLoadingMessage2,
        .recipeLoadingMessage3,
        .recipeLoadingMessage4
    ]

    // タイマー
    let iconTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    let messageTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: ds.spacing.xl) {
            Spacer()

            // アイコン（ゆらゆらアニメーション付き）
            iconImage
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isAnimating
                )

            // ProgressView
            ProgressView()
                .progressViewStyle(.circular)
                .tint(ds.colors.primaryBrand.color)
                .scaleEffect(1.3)

            // 進捗メッセージ
            Text(messages[messageIndex])
                .font(ds.typography.bodyLarge.font)
                .foregroundStyle(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: messageIndex)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, ds.spacing.lg)
        .onAppear {
            isAnimating = true
        }
        .onReceive(iconTimer) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIconIndex = (currentIconIndex + 1) % iconNames.count
            }
        }
        .onReceive(messageTimer) { _ in
            messageIndex = (messageIndex + 1) % messages.count
        }
    }

    private var iconImage: Image {
        if let uiImage = UIImage(named: iconNames[currentIconIndex], in: .app, with: nil) {
            return Image(uiImage: uiImage)
        } else {
            // フォールバック：SF Symbol
            return Image(systemName: "fork.knife")
        }
    }
}

// MARK: - Preview

#Preview("Recipe Loading") {
    NavigationStack {
        RecipeLoadingView()
            .navigationTitle("レシピを追加")
            .navigationBarTitleDisplayMode(.inline)
    }
    .prefireEnabled()
}
