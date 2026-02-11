import Foundation

/// レシピ抽出サービスのエラー
public enum RecipeExtractionError: Error, Sendable, Equatable {
    /// HTML取得に失敗（ネットワークエラー、HTTPエラー、不正なURL等）
    case htmlFetchFailed(HTMLFetcherError)
    /// APIキーが設定されていない
    case apiKeyNotConfigured
    /// レシピの解析に失敗
    case extractionFailed(String)
    /// API使用量の上限に達した
    case quotaExceeded
}

/// レシピ抽出サービスのプロトコル
public protocol RecipeExtractionServiceProtocol: Sendable {
    /// 指定したURLからレシピを抽出
    /// - Parameter url: レシピページのURL
    /// - Returns: 抽出されたRecipe
    func extractRecipe(from url: URL) async throws -> Recipe

    /// レシピの材料または工程を置き換え
    /// - Parameters:
    ///   - recipe: 置き換え対象のレシピ
    ///   - target: 置き換え対象（材料または工程）
    ///   - prompt: ユーザーの置き換え指示
    /// - Returns: 置き換え後のレシピ
    func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String
    ) async throws -> Recipe
}
