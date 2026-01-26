import Foundation
@testable import AppCore

/// テスト用のRecipeExtractionServiceモック
public final class MockRecipeExtractionService: RecipeExtractionServiceProtocol, @unchecked Sendable {
    public var recipeToReturn: Recipe?
    public var errorToThrow: Error?
    public var extractRecipeCallCount = 0
    public var lastExtractedURL: URL?

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
}
