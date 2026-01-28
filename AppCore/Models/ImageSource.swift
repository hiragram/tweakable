import Foundation
import UIKit

/// 画像ソースの種別
/// - remote: ネットワーク経由で取得する画像（AsyncImageで表示）
/// - local: ローカルファイルの画像（同期的にImageで表示）
/// - uiImage: 直接UIImageを渡す（Preview/テスト用）
public enum ImageSource: Equatable, Sendable {
    case remote(url: URL)
    case local(fileURL: URL)
    case uiImage(UIImage)

    public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
        switch (lhs, rhs) {
        case (.remote(let l), .remote(let r)):
            return l == r
        case (.local(let l), .local(let r)):
            return l == r
        case (.uiImage(let l), .uiImage(let r)):
            return l === r
        default:
            return false
        }
    }

    /// Preview/テスト用のプレースホルダー画像を生成
    public static func previewPlaceholder(
        color: UIColor = .systemGray4,
        size: CGSize = CGSize(width: 200, height: 150)
    ) -> ImageSource {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return .uiImage(image)
    }
}
