import Testing
import Foundation
@testable import AppCore

@Suite
struct OpenAIClientTests {

    // MARK: - RecipeResponse Tests

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

    // MARK: - JSON-LD Extraction Tests

    @Test
    func extractJsonLDScripts_singleScript_extractsContent() {
        let html = """
            <html>
            <head>
                <script type="application/ld+json">
                {"@type": "Recipe", "name": "Test Recipe"}
                </script>
            </head>
            </html>
            """

        let scripts = OpenAIClient.testableExtractJsonLDScripts(from: html)

        #expect(scripts.count == 1)
        #expect(scripts[0].contains("Recipe"))
    }

    @Test
    func extractJsonLDScripts_multipleScripts_extractsAll() {
        let html = """
            <html>
            <head>
                <script type="application/ld+json">{"@type": "Organization"}</script>
                <script type="application/ld+json">{"@type": "Recipe", "name": "Test"}</script>
            </head>
            </html>
            """

        let scripts = OpenAIClient.testableExtractJsonLDScripts(from: html)

        #expect(scripts.count == 2)
    }

    @Test
    func extractJsonLDScripts_noScripts_returnsEmpty() {
        let html = "<html><head><title>No JSON-LD</title></head></html>"

        let scripts = OpenAIClient.testableExtractJsonLDScripts(from: html)

        #expect(scripts.isEmpty)
    }

    @Test
    func extractJsonLDScripts_singleQuotesType_extractsContent() {
        let html = """
            <html>
            <script type='application/ld+json'>{"@type": "Recipe"}</script>
            </html>
            """

        let scripts = OpenAIClient.testableExtractJsonLDScripts(from: html)

        #expect(scripts.count == 1)
    }

    @Test
    func findRecipeInJsonLD_singleRecipe_returnsRecipe() {
        let json = """
            {"@type": "Recipe", "name": "Chocolate Cake"}
            """

        let result = OpenAIClient.testableFindRecipeInJsonLD(json)

        #expect(result != nil)
        #expect(result?["name"] as? String == "Chocolate Cake")
    }

    @Test
    func findRecipeInJsonLD_array_findsRecipe() {
        let json = """
            [
                {"@type": "Organization", "name": "Test Org"},
                {"@type": "Recipe", "name": "Apple Pie"}
            ]
            """

        let result = OpenAIClient.testableFindRecipeInJsonLD(json)

        #expect(result != nil)
        #expect(result?["name"] as? String == "Apple Pie")
    }

    @Test
    func findRecipeInJsonLD_graphStructure_findsRecipe() {
        let json = """
            {
                "@context": "https://schema.org",
                "@graph": [
                    {"@type": "WebPage", "name": "Page"},
                    {"@type": "Recipe", "name": "Pasta"}
                ]
            }
            """

        let result = OpenAIClient.testableFindRecipeInJsonLD(json)

        #expect(result != nil)
        #expect(result?["name"] as? String == "Pasta")
    }

    @Test
    func findRecipeInJsonLD_typeArray_findsRecipe() {
        let json = """
            {"@type": ["Article", "Recipe"], "name": "Mixed Type Recipe"}
            """

        let result = OpenAIClient.testableFindRecipeInJsonLD(json)

        #expect(result != nil)
        #expect(result?["name"] as? String == "Mixed Type Recipe")
    }

    @Test
    func findRecipeInJsonLD_noRecipe_returnsNil() {
        let json = """
            {"@type": "Organization", "name": "Not a Recipe"}
            """

        let result = OpenAIClient.testableFindRecipeInJsonLD(json)

        #expect(result == nil)
    }

    @Test
    func findRecipeInJsonLD_invalidJson_returnsNil() {
        let json = "not valid json"

        let result = OpenAIClient.testableFindRecipeInJsonLD(json)

        #expect(result == nil)
    }

    @Test
    func extractRecipeJsonLD_fullHTML_extractsRecipe() {
        let html = """
            <html>
            <head>
                <script type="application/ld+json">
                {
                    "@context": "https://schema.org",
                    "@type": "Recipe",
                    "name": "Full Recipe",
                    "recipeIngredient": ["flour", "sugar"]
                }
                </script>
            </head>
            </html>
            """

        let result = OpenAIClient.testableExtractRecipeJsonLD(from: html)

        #expect(result != nil)
        #expect(result?.contains("Full Recipe") == true)
    }

    @Test
    func extractRecipeJsonLD_noRecipeInJsonLD_returnsNil() {
        let html = """
            <html>
            <head>
                <script type="application/ld+json">
                {"@type": "Organization", "name": "Not Recipe"}
                </script>
            </head>
            </html>
            """

        let result = OpenAIClient.testableExtractRecipeJsonLD(from: html)

        #expect(result == nil)
    }

    // MARK: - decodeRecipe Error Handling Tests

    @Test
    func decodeRecipe_noContent_throwsNoResponseContentError() {
        let sourceURL = URL(string: "https://example.com/recipe")!

        #expect(throws: OpenAIClientError.noResponseContent) {
            _ = try OpenAIClient.testableDecodeRecipe(content: nil, sourceURL: sourceURL)
        }
    }

    @Test
    func decodeRecipe_invalidJson_throwsDecodingError() {
        let sourceURL = URL(string: "https://example.com/recipe")!
        let invalidJson = "not a valid json"

        do {
            _ = try OpenAIClient.testableDecodeRecipe(content: invalidJson, sourceURL: sourceURL)
            Issue.record("Expected decodingError to be thrown")
        } catch {
            if case OpenAIClientError.decodingError = error {
                // Expected
            } else {
                Issue.record("Expected OpenAIClientError.decodingError, got \(error)")
            }
        }
    }

    @Test
    func decodeRecipe_missingRequiredFields_throwsDecodingError() {
        let sourceURL = URL(string: "https://example.com/recipe")!
        // title is required but missing
        let incompleteJson = """
            {
                "description": "Test",
                "imageURLs": [],
                "ingredients": [],
                "steps": []
            }
            """

        do {
            _ = try OpenAIClient.testableDecodeRecipe(content: incompleteJson, sourceURL: sourceURL)
            Issue.record("Expected decodingError to be thrown")
        } catch {
            if case OpenAIClientError.decodingError = error {
                // Expected
            } else {
                Issue.record("Expected OpenAIClientError.decodingError, got \(error)")
            }
        }
    }

    @Test
    func decodeRecipe_validJson_returnsRecipe() throws {
        let sourceURL = URL(string: "https://example.com/recipe")!
        let validJson = """
            {
                "title": "Test Recipe",
                "description": "A test recipe",
                "imageURLs": ["https://example.com/image.jpg"],
                "servings": "4人分",
                "ingredients": [
                    {"name": "Flour", "amount": "2 cups"}
                ],
                "steps": [
                    {"stepNumber": 1, "instruction": "Mix ingredients", "imageURLs": []}
                ]
            }
            """

        let recipe = try OpenAIClient.testableDecodeRecipe(content: validJson, sourceURL: sourceURL)

        #expect(recipe.title == "Test Recipe")
        #expect(recipe.ingredientsInfo.items.count == 1)
        #expect(recipe.steps.count == 1)
    }

    // MARK: - prepareContent Tests

    @Test
    func prepareContent_noJsonLD_usesHTML() {
        // JSON-LDを含まないHTML
        let html = "<html><body><h1>Recipe without JSON-LD</h1><p>Ingredients: flour, sugar</p></body></html>"

        let (content, type) = OpenAIClient.testablePrepareContent(from: html)

        // HTMLが使用されることを確認
        #expect(type == "HTML")
        #expect(content.hasPrefix("HTML:\n"))
        #expect(content.contains(html))
    }

    @Test
    func prepareContent_withJsonLD_usesJsonLD() {
        // JSON-LDを含むHTML
        let html = """
            <html>
            <head>
                <script type="application/ld+json">
                {"@type": "Recipe", "name": "Test Recipe", "recipeIngredient": ["flour"]}
                </script>
            </head>
            <body><h1>Recipe Page</h1></body>
            </html>
            """

        let (content, type) = OpenAIClient.testablePrepareContent(from: html)

        // JSON-LDが使用されることを確認
        #expect(type == "JSON-LD")
        #expect(content.hasPrefix("JSON-LD Recipe Data:\n"))
        #expect(content.contains("Test Recipe"))
    }

    @Test
    func prepareContent_nonRecipeJsonLD_usesHTML() {
        // RecipeではないJSON-LDを含むHTML
        let html = """
            <html>
            <head>
                <script type="application/ld+json">
                {"@type": "Organization", "name": "Test Org"}
                </script>
            </head>
            <body><h1>Organization Page</h1></body>
            </html>
            """

        let (content, type) = OpenAIClient.testablePrepareContent(from: html)

        // Recipe型ではないので、HTMLにフォールバックすることを確認
        #expect(type == "HTML")
        #expect(content.hasPrefix("HTML:\n"))
    }
}
