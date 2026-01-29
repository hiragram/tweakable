import Foundation
import UIKit

/// 画像ソースの種別を表すenum
///
/// ## ユースケース
/// - `remote`: レシピサイトから取得した画像URL（AsyncImageで非同期表示）
/// - `local`: デバイスに保存された画像ファイル（同期的にImageで表示）
/// - `uiImage`: Preview/テスト用に直接UIImageを渡す場合
///
/// ## 等価性
/// - `remote`, `local`: URLの値で比較
/// - `uiImage`: インスタンスの同一性（参照比較）で判定
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
            // UIImageは値比較が高コストなため、参照比較（同一インスタンスか）で判定
            return l === r
        default:
            return false
        }
    }

    // MARK: - Preview/Test Helpers

    /// デフォルト引数用のキャッシュ済みプレースホルダー画像
    private static let cachedDefaultPlaceholder: UIImage = {
        let size = CGSize(width: 200, height: 150)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray4.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()

    /// Preview/テスト用のプレースホルダー画像を生成
    ///
    /// デフォルト引数で呼び出した場合は静的キャッシュを使用し、
    /// 毎回新しいUIImageを生成するオーバーヘッドを回避する。
    public static func previewPlaceholder(
        color: UIColor = .systemGray4,
        size: CGSize = CGSize(width: 200, height: 150)
    ) -> ImageSource {
        // デフォルト引数の場合はキャッシュを使用
        if color == .systemGray4 && size == CGSize(width: 200, height: 150) {
            return .uiImage(cachedDefaultPlaceholder)
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return .uiImage(image)
    }
}
