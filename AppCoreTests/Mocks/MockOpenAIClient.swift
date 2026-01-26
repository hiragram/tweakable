import Foundation
@testable import AppCore

/// OpenAIClientのMock実装
final class MockOpenAIClient: OpenAIClientProtocol, @unchecked Sendable {
    /// テスト用: 返すレシピ（extractRecipeとsubstituteRecipeで共有）
    var recipe: Recipe?

    /// テスト用: substituteRecipeで返すレシピ（設定されていればこちらを優先）
    var substitutedRecipe: Recipe?

    /// テスト用: 発生させるエラー
    var error: OpenAIClientError?

    /// テスト用: substituteRecipeで発生させるエラー（設定されていればこちらを優先）
    var substitutionError: OpenAIClientError?

    /// テスト用: extractRecipe呼び出し記録
    private(set) var extractRecipeCalls: [(html: String, sourceURL: URL, targetLanguage: String)] = []

    /// テスト用: substituteRecipe呼び出し記録
    private(set) var substituteRecipeCalls: [(recipe: Recipe, target: SubstitutionTarget, prompt: String, targetLanguage: String)] = []

    /// テスト用: extractRecipe呼び出し回数
    var extractRecipeCallCount: Int { extractRecipeCalls.count }

    /// テスト用: substituteRecipe呼び出し回数
    var substituteRecipeCallCount: Int { substituteRecipeCalls.count }

    /// テスト用: 最後に渡されたtargetLanguage
    var lastTargetLanguage: String? { extractRecipeCalls.last?.targetLanguage }

    /// テスト用: 最後に渡されたsubstitutionのprompt
    var lastSubstitutionPrompt: String? { substituteRecipeCalls.last?.prompt }

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

    func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String,
        targetLanguage: String
    ) async throws -> Recipe {
        substituteRecipeCalls.append((recipe: recipe, target: target, prompt: prompt, targetLanguage: targetLanguage))

        // substituteRecipe専用のエラーがあればそちらを使う
        if let substitutionError = substitutionError {
            throw substitutionError
        }

        // 汎用エラーがあればそちらを使う
        if let error = error {
            throw error
        }

        // substituteRecipe専用のレシピがあればそちらを返す
        if let substitutedRecipe = substitutedRecipe {
            return substitutedRecipe
        }

        // 汎用レシピがあればそちらを返す
        guard let recipe = self.recipe else {
            throw OpenAIClientError.noResponseContent
        }

        return recipe
    }
}
