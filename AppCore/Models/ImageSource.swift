import Foundation
import UIKit

/// 画像ソースの種別を表すenum
///
/// ## ユースケース
/// - `remote`: レシピサイトから取得した画像URL（NukeUI LazyImageで非同期表示、キャッシュあり）
/// - `local`: デバイスに保存された画像ファイル（同期的にImageで表示）
/// - `uiImage`: Preview/テスト用に直接UIImageを渡す場合
/// - `bundled`: アプリバンドルに含まれる画像（アセットカタログ、シードデータに使用）
///
/// ## 等価性
/// - `remote`, `local`: URLの値で比較
/// - `uiImage`: インスタンスの同一性（参照比較）で判定
/// - `bundled`: 画像名（String）の値で比較
public enum ImageSource: Equatable, Sendable {
    case remote(url: URL)
    case local(fileURL: URL)
    case uiImage(UIImage)
    case bundled(name: String)

    public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
        switch (lhs, rhs) {
        case (.remote(let l), .remote(let r)):
            return l == r
        case (.local(let l), .local(let r)):
            return l == r
        case (.uiImage(let l), .uiImage(let r)):
            // UIImageは値比較が高コストなため、参照比較（同一インスタンスか）で判定
            return l === r
        case (.bundled(let l), .bundled(let r)):
            return l == r
        default:
            return false
        }
    }

    // MARK: - Persistence

    /// 永続化用のプレフィックス
    static let bundledPrefix = "bundled://"

    /// 永続化用の文字列表現に変換
    ///
    /// - Returns:
    ///   - `.remote`: URL文字列をそのまま返す（例: `"https://example.com/image.jpg"`）
    ///   - `.bundled`: `"bundled://"` プレフィックス + 画像名（例: `"bundled://seed-shakshuka"`）
    ///   - `.local`, `.uiImage`: `nil`（一時的な画像のため永続化対象外）
    func toPersistenceString() -> String? {
        switch self {
        case .remote(let url):
            return url.absoluteString
        case .bundled(let name):
            return "\(Self.bundledPrefix)\(name)"
        default:
            return nil
        }
    }

    /// 永続化文字列からImageSourceを復元
    ///
    /// - Parameter string: `toPersistenceString()` が生成した文字列
    /// - Returns:
    ///   - `"bundled://"` で始まる場合: `.bundled` ケース
    ///   - それ以外で有効なURL: `.remote` ケース
    ///   - 無効な文字列: `nil`
    static func fromPersistenceString(_ string: String) -> ImageSource? {
        if string.hasPrefix(bundledPrefix) {
            return .bundled(name: String(string.dropFirst(bundledPrefix.count)))
        }
        guard let url = URL(string: string) else { return nil }
        return .remote(url: url)
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
