import Foundation

/// レシピ抽出サービスのエラー
public enum RecipeExtractionError: Error, Sendable, Equatable {
    case htmlFetchFailed(String)
    case apiKeyNotConfigured
    case extractionFailed(String)
}

/// レシピ抽出サービスのプロトコル
public protocol RecipeExtractionServiceProtocol: Sendable {
    /// 指定したURLからレシピを抽出
    /// - Parameter url: レシピページのURL
    /// - Returns: 抽出されたRecipe
    func extractRecipe(from url: URL) async throws -> Recipe
}
