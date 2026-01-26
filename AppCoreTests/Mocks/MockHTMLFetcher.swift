import Foundation
@testable import AppCore

/// HTMLFetcherのMock実装
final class MockHTMLFetcher: HTMLFetcherProtocol, @unchecked Sendable {
    /// テスト用: 返すHTML
    var html: String?

    /// テスト用: 発生させるエラー
    var error: HTMLFetcherError?

    /// テスト用: 呼び出されたURLを記録
    private(set) var fetchedURLs: [URL] = []

    /// テスト用: 呼び出し回数
    var fetchHTMLCallCount: Int { fetchedURLs.count }

    init(html: String? = nil, error: HTMLFetcherError? = nil) {
        self.html = html
        self.error = error
    }

    func fetchHTML(from url: URL) async throws -> String {
        fetchedURLs.append(url)

        if let error = error {
            throw error
        }

        guard let html = html else {
            throw HTMLFetcherError.noData
        }

        return html
    }
}
