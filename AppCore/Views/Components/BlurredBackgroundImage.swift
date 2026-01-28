import SwiftUI

/// ブラー背景付き画像コンポーネント（Instagram Reels風）
///
/// 背景にブラー＋暗めのscaledToFill画像を敷き、
/// 前景にシャープなscaledToFit画像を重ねて表示する。
/// アスペクト比が異なる画像でも余白が自然に埋まる。
///
/// - Warning: ブラーは視覚的な装飾目的であり、機密情報の隠蔽には使用しないこと。
///   ブラーされた画像から元の情報を復元できる可能性がある。
struct BlurredBackgroundImage: View {
    private let image: Image
    private let height: CGFloat
    private let blurRadius: CGFloat
    private let overlayOpacity: Double

    /// - Parameters:
    ///   - image: 表示する画像
    ///   - height: コンポーネントの高さ
    ///   - blurRadius: 背景のブラー半径（デフォルト: 20）
    ///   - overlayOpacity: 背景の黒オーバーレイの不透明度（デフォルト: 0.02）
    init(
        image: Image,
        height: CGFloat,
        blurRadius: CGFloat = 20,
        overlayOpacity: Double = 0.02
    ) {
        self.image = image
        self.height = height
        self.blurRadius = blurRadius
        self.overlayOpacity = overlayOpacity
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景: ブラーをかけたscaledToFill画像 + 半透明の黒オーバーレイ
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: height)
                    .clipped()
                    .blur(radius: blurRadius)
                    .overlay(Color.black.opacity(overlayOpacity))


                // 前景: 横幅いっぱいに収めて、高さは成り行き（中央揃え）
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .frame(maxHeight: height)
            }
            .frame(width: geometry.size.width, height: height)
            .clipped()
        }
        .frame(height: height)
    }
}

// MARK: - Preview

#Preview("Square Image") {
    BlurredBackgroundImage(
        image: Image(systemName: "photo.fill"),
        height: 300
    )
}

#Preview("Custom Settings") {
    BlurredBackgroundImage(
        image: Image(systemName: "photo.fill"),
        height: 200,
        blurRadius: 30,
        overlayOpacity: 0.5
    )
}

#Preview("Async Remote Image") {
    AsyncImage(url: URL(string: "https://img-global-jp.cpcdn.com/recipes/a74bad56b72e6dab/1280x1280sq80/photo.webp")!) { phase in
        switch phase {
        case .success(let image):
            BlurredBackgroundImage(image: image, height: 400)
        default:
            Color.clear
        }
    }
}
