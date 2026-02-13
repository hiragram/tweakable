import NukeUI
import SwiftUI

// MARK: - RecipeImageView

/// レシピ画像を表示する共通コンポーネント
///
/// `ImageSource`の種類（リモートURL、ローカルファイル、UIImage、バンドル画像）に応じて
/// 適切な方法で画像を表示する。画像がない場合やロード失敗時はプレースホルダーを表示する。
struct RecipeImageView: View {
    private let ds = DesignSystem.default

    let source: ImageSource?
    let size: CGFloat
    let cornerRadius: CGFloat
    let placeholderIconSize: CGFloat?

    init(
        source: ImageSource?,
        size: CGFloat = 60,
        cornerRadius: CGFloat? = nil,
        placeholderIconSize: CGFloat? = nil
    ) {
        self.source = source
        self.size = size
        self.cornerRadius = cornerRadius ?? DesignSystem.default.cornerRadius.sm
        self.placeholderIconSize = placeholderIconSize
    }

    var body: some View {
        imageContent
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    // MARK: - Image Content

    @ViewBuilder
    private var imageContent: some View {
        if let source {
            switch source {
            case .remote(let url):
                LazyImage(url: url) { state in
                    if state.isLoading {
                        placeholderImage
                            .overlay {
                                ProgressView()
                                    .scaleEffect(size <= 50 ? 0.5 : 0.6)
                            }
                    } else if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderImage
                    }
                }
            case .local(let fileURL):
                if let data = try? Data(contentsOf: fileURL),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholderImage
                }
            case .uiImage(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .bundled(let name):
                if let uiImage = UIImage(named: name, in: .app, with: nil) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    // MARK: - Placeholder

    private var placeholderImage: some View {
        Rectangle()
            .fill(ds.colors.backgroundSecondary.color)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(placeholderIconSize.map { .system(size: $0) })
                    .foregroundColor(ds.colors.textTertiary.color)
            }
    }
}
