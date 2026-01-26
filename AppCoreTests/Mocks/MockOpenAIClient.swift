import Foundation
@testable import AppCore

/// OpenAIClientのMock実装
final class MockOpenAIClient: OpenAIClientProtocol, @unchecked Sendable {
    /// テスト用: 返すレシピ
    var recipe: Recipe?

    /// テスト用: 発生させるエラー
    var error: OpenAIClientError?

    /// テスト用: 呼び出し記録
    private(set) var extractRecipeCalls: [(html: String, sourceURL: URL, targetLanguage: String)] = []

    /// テスト用: 呼び出し回数
    var extractRecipeCallCount: Int { extractRecipeCalls.count }

    /// テスト用: 最後に渡されたtargetLanguage
    var lastTargetLanguage: String? { extractRecipeCalls.last?.targetLanguage }

    init(recipe: Recipe? = nil, error: OpenAIClientError? = nil) {
        self.recipe = recipe
        self.error = error
    }

    func extractRecipe(html: String, sourceURL: URL, targetLanguage: String) async throws -> Recipe {
        extractRecipeCalls.append((html: html, sourceURL: sourceURL, targetLanguage: targetLanguage))

        if let error = error {
            throw error
        }

        guard let recipe = recipe else {
            throw OpenAIClientError.noResponseContent
        }

        return recipe
    }
}
