import Foundation
import Nuke

/// シードデータの画像をバックグラウンドでプリフェッチするサービス
///
/// オンボーディング画面表示中にプリフェッチを開始し、
/// ユーザーがRecipeHome画面に遷移した時点でキャッシュから即座に表示できるようにする。
/// LazyImageと同じImagePipeline.sharedを使用するため、
/// プリフェッチした画像はLazyImageが自動的にキャッシュから読み込む。
@MainActor
final class ImagePrefetchService {
    private let prefetcher: ImagePrefetcher

    init() {
        self.prefetcher = ImagePrefetcher(
            pipeline: .shared,
            destination: .memoryCache,
            maxConcurrentRequestCount: 2
        )
        prefetcher.priority = .veryLow
    }

    /// シードデータの画像URLをプリフェッチ開始
    func startPrefetchingSeedImages() {
        let urls: [URL] = SeedData.recipes().compactMap { recipe in
            guard let first = recipe.imageURLs.first else { return nil }
            switch first {
            case .remote(let url):
                return url
            default:
                return nil
            }
        }

        guard !urls.isEmpty else { return }
        prefetcher.startPrefetching(with: urls)
    }
}
