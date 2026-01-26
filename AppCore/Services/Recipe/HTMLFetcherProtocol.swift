import Foundation

/// HTML取得サービスのエラー
public enum HTMLFetcherError: Error, Sendable, Equatable {
    case invalidURL
    case networkError(String)
    case httpError(statusCode: Int)
    case noData
    case decodingError
}

/// HTML取得サービスのプロトコル
public protocol HTMLFetcherProtocol: Sendable {
    /// 指定したURLからHTMLを取得
    /// - Parameter url: 取得するURL
    /// - Returns: HTML文字列
    func fetchHTML(from url: URL) async throws -> String
}
