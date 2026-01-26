import Testing
import Foundation
@testable import AppCore

@Suite
struct OpenAIClientTests {
    @Test
    func recipeResponse_toRecipe_convertsCorrectly() async throws {
        let response = RecipeResponse(
            title: "テストレシピ",
            description: "テスト用のレシピです",
            imageURLs: ["https://example.com/image.jpg"],
            servings: "2人分",
            ingredients: [
                .init(name: "玉ねぎ", amount: "1個"),
                .init(name: "にんじん", amount: "1本")
            ],
            steps: [
                .init(stepNumber: 1, instruction: "野菜を切る", imageURLs: nil),
                .init(stepNumber: 2, instruction: "炒める", imageURLs: ["https://example.com/step2.jpg"])
            ]
        )

        let recipe = response.toRecipe(sourceURL: URL(string: "https://example.com/recipe")!)

        #expect(recipe.title == "テストレシピ")
        #expect(recipe.description == "テスト用のレシピです")
        #expect(recipe.imageURLs.count == 1)
        #expect(recipe.ingredientsInfo.servings == "2人分")
        #expect(recipe.ingredientsInfo.items.count == 2)
        #expect(recipe.ingredientsInfo.items[0].name == "玉ねぎ")
        #expect(recipe.ingredientsInfo.items[0].amount == "1個")
        #expect(recipe.steps.count == 2)
        #expect(recipe.steps[0].instruction == "野菜を切る")
        #expect(recipe.steps[1].imageURLs.count == 1)
        #expect(recipe.sourceURL?.absoluteString == "https://example.com/recipe")
    }

    @Test
    func extractRecipe_apiKeyNotConfigured_throwsError() async throws {
        let mockConfig = MockConfigurationService(apiKey: nil)
        let client = OpenAIClient(configurationService: mockConfig)

        await #expect(throws: OpenAIClientError.apiKeyNotConfigured) {
            try await client.extractRecipe(
                html: "<html></html>",
                sourceURL: URL(string: "https://example.com")!,
                targetLanguage: "ja"
            )
        }
    }
}
