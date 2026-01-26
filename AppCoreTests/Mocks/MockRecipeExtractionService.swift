import Foundation
@testable import AppCore

/// テスト用のRecipeExtractionServiceモック
public final class MockRecipeExtractionService: RecipeExtractionServiceProtocol, @unchecked Sendable {
    public var recipeToReturn: Recipe?
    public var errorToThrow: Error?
    public var extractRecipeCallCount = 0
    public var lastExtractedURL: URL?

    // substituteRecipe用のプロパティ
    public var substitutedRecipe: Recipe?
    public var substitutionError: Error?
    public var substituteRecipeCallCount = 0
    public var lastSubstitutionTarget: SubstitutionTarget?
    public var lastSubstitutionPrompt: String?

    public init(recipe: Recipe? = nil, error: Error? = nil) {
        self.recipeToReturn = recipe
        self.errorToThrow = error
    }

    public func extractRecipe(from url: URL) async throws -> Recipe {
        extractRecipeCallCount += 1
        lastExtractedURL = url

        if let error = errorToThrow {
            throw error
        }

        guard let recipe = recipeToReturn else {
            throw RecipeExtractionError.extractionFailed("No mock recipe configured")
        }

        return recipe
    }

    public func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String
    ) async throws -> Recipe {
        substituteRecipeCallCount += 1
        lastSubstitutionTarget = target
        lastSubstitutionPrompt = prompt

        if let error = substitutionError {
            throw error
        }

        guard let result = substitutedRecipe else {
            throw RecipeExtractionError.extractionFailed("No mock substituted recipe configured")
        }

        return result
    }
}
