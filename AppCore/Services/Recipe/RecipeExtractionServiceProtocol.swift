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
