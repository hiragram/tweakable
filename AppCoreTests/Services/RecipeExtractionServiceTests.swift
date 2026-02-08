import Foundation
import Testing
@testable import AppCore

@Suite
struct RecipeExtractionServiceTests {

    // MARK: - Test Helpers

    private func makeMockRecipe() -> Recipe {
        Recipe(
            title: "テストレシピ",
            description: "テスト用の説明",
            imageURLs: [.remote(url: URL(string: "https://example.com/image.jpg")!)],
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(items: [
                        Ingredient(name: "玉ねぎ", amount: "1個"),
                        Ingredient(name: "にんじん", amount: "1本")
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                    CookingStep(stepNumber: 2, instruction: "炒める")
                ])
            ],
            sourceURL: URL(string: "https://example.com/recipe")
        )
    }

    // MARK: - extractRecipe Tests

    @Test
    func extractRecipe_success_returnsRecipe() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html><body>Recipe content</body></html>")
        let expectedRecipe = makeMockRecipe()
        let mockOpenAI = MockOpenAIClient(recipe: expectedRecipe)
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let url = URL(string: "https://example.com/recipe")!

        // Act
        let recipe = try await service.extractRecipe(from: url)

        // Assert
        #expect(recipe.title == "テストレシピ")
        #expect(recipe.ingredientsInfo.allItems.count == 2)
        #expect(recipe.allSteps.count == 2)
        #expect(mockHTML.fetchHTMLCallCount == 1)
        #expect(mockOpenAI.extractRecipeCallCount == 1)
    }

    @Test
    func extractRecipe_htmlFetchFails_throwsHTMLFetchError() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(error: HTMLFetcherError.networkError("Connection failed"))
        let mockOpenAI = MockOpenAIClient(recipe: makeMockRecipe())
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let url = URL(string: "https://example.com/recipe")!

        // Act & Assert
        await #expect(throws: RecipeExtractionError.self) {
            try await service.extractRecipe(from: url)
        }
    }

    @Test
    func extractRecipe_openAIFails_throwsExtractionError() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html><body>Recipe content</body></html>")
        let mockOpenAI = MockOpenAIClient(error: OpenAIClientError.networkError("API error"))
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let url = URL(string: "https://example.com/recipe")!

        // Act & Assert
        await #expect(throws: RecipeExtractionError.self) {
            try await service.extractRecipe(from: url)
        }
    }

    @Test
    func extractRecipe_passesCorrectLanguage() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html><body>Recipe content</body></html>")
        let expectedRecipe = makeMockRecipe()
        let mockOpenAI = MockOpenAIClient(recipe: expectedRecipe)
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let url = URL(string: "https://example.com/recipe")!

        // Act
        _ = try await service.extractRecipe(from: url)

        // Assert
        // OpenAIClientにtargetLanguageが渡されていることを確認
        #expect(mockOpenAI.lastTargetLanguage != nil)
    }

    @Test
    func extractRecipe_apiKeyNotConfigured_throwsApiKeyNotConfiguredError() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html><body>Recipe content</body></html>")
        let mockOpenAI = MockOpenAIClient(error: .apiKeyNotConfigured)
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let url = URL(string: "https://example.com/recipe")!

        // Act & Assert
        // OpenAIClientError.apiKeyNotConfiguredがRecipeExtractionError.apiKeyNotConfiguredに変換されることを確認
        await #expect(throws: RecipeExtractionError.apiKeyNotConfigured) {
            try await service.extractRecipe(from: url)
        }
    }

    @Test
    func extractRecipe_otherOpenAIError_throwsExtractionFailed() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html><body>Recipe content</body></html>")
        let mockOpenAI = MockOpenAIClient(error: .noResponseContent)
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let url = URL(string: "https://example.com/recipe")!

        // Act & Assert
        // OpenAIClientError.noResponseContentはRecipeExtractionError.extractionFailedに変換されることを確認
        do {
            _ = try await service.extractRecipe(from: url)
            Issue.record("Expected error to be thrown")
        } catch {
            if case RecipeExtractionError.extractionFailed = error {
                // Expected
            } else if case RecipeExtractionError.apiKeyNotConfigured = error {
                Issue.record("Expected extractionFailed, but got apiKeyNotConfigured")
            } else {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }

    // MARK: - substituteRecipe Tests

    @Test
    func substituteRecipe_success_returnsRecipe() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html></html>")
        let originalRecipe = makeMockRecipe()
        let expectedRecipe = Recipe(
            title: "置き換え後レシピ",
            description: "置き換え後の説明",
            imageURLs: [.remote(url: URL(string: "https://example.com/image.jpg")!)],
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(items: [
                        Ingredient(name: "かぼちゃ", amount: "1/4個"),
                        Ingredient(name: "にんじん", amount: "1本")
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                    CookingStep(stepNumber: 2, instruction: "炒める")
                ])
            ],
            sourceURL: URL(string: "https://example.com/recipe")
        )
        let mockOpenAI = MockOpenAIClient(recipe: originalRecipe)
        mockOpenAI.substitutedRecipe = expectedRecipe
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let target = SubstitutionTarget.ingredient(originalRecipe.ingredientsInfo.allItems[0])

        // Act
        let result = try await service.substituteRecipe(
            recipe: originalRecipe,
            target: target,
            prompt: "玉ねぎをかぼちゃに"
        )

        // Assert
        #expect(result.title == expectedRecipe.title)
        #expect(mockOpenAI.substituteRecipeCallCount == 1)
    }

    @Test
    func substituteRecipe_apiKeyNotConfigured_throwsApiKeyNotConfiguredError() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html></html>")
        let originalRecipe = makeMockRecipe()
        let mockOpenAI = MockOpenAIClient(recipe: originalRecipe)
        mockOpenAI.substitutionError = .apiKeyNotConfigured
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let target = SubstitutionTarget.ingredient(originalRecipe.ingredientsInfo.allItems[0])

        // Act & Assert
        await #expect(throws: RecipeExtractionError.apiKeyNotConfigured) {
            try await service.substituteRecipe(
                recipe: originalRecipe,
                target: target,
                prompt: "置き換えて"
            )
        }
    }

    @Test
    func substituteRecipe_otherError_throwsExtractionFailed() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html></html>")
        let originalRecipe = makeMockRecipe()
        let mockOpenAI = MockOpenAIClient(recipe: originalRecipe)
        mockOpenAI.substitutionError = .noResponseContent
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let target = SubstitutionTarget.ingredient(originalRecipe.ingredientsInfo.allItems[0])

        // Act & Assert
        do {
            _ = try await service.substituteRecipe(
                recipe: originalRecipe,
                target: target,
                prompt: "置き換えて"
            )
            Issue.record("Expected error to be thrown")
        } catch {
            if case RecipeExtractionError.extractionFailed = error {
                // Expected
            } else if case RecipeExtractionError.apiKeyNotConfigured = error {
                Issue.record("Expected extractionFailed, but got apiKeyNotConfigured")
            } else {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }

    @Test
    func substituteRecipe_passesCorrectTargetAndPrompt() async throws {
        // Arrange
        let mockHTML = MockHTMLFetcher(html: "<html></html>")
        let originalRecipe = makeMockRecipe()
        let mockOpenAI = MockOpenAIClient(recipe: originalRecipe)
        mockOpenAI.substitutedRecipe = originalRecipe
        let mockConfig = MockConfigurationService(apiKey: "test-api-key")

        let service = RecipeExtractionService(
            htmlFetcher: mockHTML,
            openAIClient: mockOpenAI,
            configurationService: mockConfig
        )

        let targetIngredient = originalRecipe.ingredientsInfo.allItems[0]
        let target = SubstitutionTarget.ingredient(targetIngredient)
        let prompt = "玉ねぎをかぼちゃに変えて"

        // Act
        _ = try await service.substituteRecipe(
            recipe: originalRecipe,
            target: target,
            prompt: prompt
        )

        // Assert
        #expect(mockOpenAI.substituteRecipeCallCount == 1)
        #expect(mockOpenAI.lastSubstitutionPrompt == prompt)
        let lastCall = mockOpenAI.substituteRecipeCalls.last
        #expect(lastCall?.target == target)
        #expect(lastCall?.targetLanguage != nil)
    }
}
