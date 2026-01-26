import Foundation

/// URLSessionプロトコル（テスト用に抽象化）
public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// 標準のURLSessionにプロトコル適合
extension URLSession: URLSessionProtocol {}

/// HTML取得サービスの実装
public struct HTMLFetcher: HTMLFetcherProtocol, Sendable {
    private let session: URLSessionProtocol

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    public func fetchHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        // ボット検出回避のためSafari/iPhoneのUser-Agentを設定
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw HTMLFetcherError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTMLFetcherError.networkError("Invalid response type")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTMLFetcherError.httpError(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw HTMLFetcherError.noData
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw HTMLFetcherError.decodingError
        }

        return html
    }
}
