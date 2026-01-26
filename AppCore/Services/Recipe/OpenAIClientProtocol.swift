import Foundation

/// OpenAIクライアントのエラー
public enum OpenAIClientError: Error, Sendable, Equatable {
    case apiKeyNotConfigured
    case networkError(String)
    case noResponseContent
    case decodingError(String)
}

/// OpenAIクライアントのプロトコル
public protocol OpenAIClientProtocol: Sendable {
    /// HTMLからレシピを抽出
    /// - Parameters:
    ///   - html: レシピページのHTML
    ///   - sourceURL: レシピのソースURL
    ///   - targetLanguage: 出力言語（例: "ja", "en"）
    /// - Returns: 抽出されたRecipe
    func extractRecipe(html: String, sourceURL: URL, targetLanguage: String) async throws -> Recipe
}
