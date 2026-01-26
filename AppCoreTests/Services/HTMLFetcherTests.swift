import Testing
import Foundation
@testable import AppCore

@Suite
struct HTMLFetcherTests {
    @Test
    func fetchHTML_validURL_returnsHTMLString() async throws {
        // 実際のURLSessionを使うとネットワークに依存するので
        // テスト用のMockURLSessionを使う
        let mockSession = MockURLSession()
        mockSession.data = "<html><body>Test</body></html>".data(using: .utf8)
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let fetcher = HTMLFetcher(session: mockSession)
        let html = try await fetcher.fetchHTML(from: URL(string: "https://example.com")!)

        #expect(html.contains("<html>"))
        #expect(html.contains("Test"))
    }

    @Test
    func fetchHTML_httpError_throwsHTTPError() async throws {
        let mockSession = MockURLSession()
        mockSession.data = Data()
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        let fetcher = HTMLFetcher(session: mockSession)

        await #expect(throws: HTMLFetcherError.httpError(statusCode: 404)) {
            try await fetcher.fetchHTML(from: URL(string: "https://example.com")!)
        }
    }

    @Test
    func fetchHTML_networkError_throwsNetworkError() async throws {
        let mockSession = MockURLSession()
        mockSession.error = URLError(.notConnectedToInternet)

        let fetcher = HTMLFetcher(session: mockSession)

        await #expect(throws: HTMLFetcherError.self) {
            try await fetcher.fetchHTML(from: URL(string: "https://example.com")!)
        }
    }

    @Test
    func fetchHTML_emptyData_throwsNoDataError() async throws {
        let mockSession = MockURLSession()
        mockSession.data = Data() // 空データ
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let fetcher = HTMLFetcher(session: mockSession)

        await #expect(throws: HTMLFetcherError.noData) {
            try await fetcher.fetchHTML(from: URL(string: "https://example.com")!)
        }
    }

    @Test
    func fetchHTML_invalidEncoding_throwsDecodingError() async throws {
        let mockSession = MockURLSession()
        // UTF-8でデコードできないバイト列
        mockSession.data = Data([0xFF, 0xFE, 0xFD])
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let fetcher = HTMLFetcher(session: mockSession)

        await #expect(throws: HTMLFetcherError.decodingError) {
            try await fetcher.fetchHTML(from: URL(string: "https://example.com")!)
        }
    }
}

// MARK: - MockURLSession

/// URLSessionのモック
final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }

        guard let data = data, let response = response else {
            throw URLError(.unknown)
        }

        return (data, response)
    }
}
