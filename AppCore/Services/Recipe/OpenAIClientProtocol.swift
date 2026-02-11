import Foundation

/// OpenAIクライアントのエラー
public enum OpenAIClientError: Error, Sendable, Equatable {
    case apiKeyNotConfigured
    case networkError(String)
    case noResponseContent
    case decodingError(String)
    /// API使用量の上限に達した（OpenAI APIのinsufficient_quota）
    case quotaExceeded
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

    /// レシピの材料または調理工程を置き換える
    /// - Parameters:
    ///   - recipe: 現在のレシピ
    ///   - target: 置き換え対象（材料または工程）
    ///   - prompt: ユーザーの置き換え指示
    ///   - targetLanguage: 出力言語（例: "ja", "en"）
    /// - Returns: 置き換え後のRecipe
    func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String,
        targetLanguage: String
    ) async throws -> Recipe
}
