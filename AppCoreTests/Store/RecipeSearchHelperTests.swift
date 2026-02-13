import Testing
import Foundation
@testable import AppCore

@Suite
struct RecipeSearchHelperTests {

    // MARK: - Test Helpers

    private func makeRecipe(
        title: String = "テスト料理",
        description: String? = nil,
        ingredientNames: [String] = [],
        stepInstructions: [String] = []
    ) -> Recipe {
        Recipe(
            title: title,
            description: description,
            ingredientsInfo: Ingredients(
                sections: [
                    IngredientSection(items: ingredientNames.map { Ingredient(name: $0, amount: "適量") })
                ]
            ),
            stepSections: [
                CookingStepSection(items: stepInstructions.enumerated().map { index, instruction in
                    CookingStep(stepNumber: index + 1, instruction: instruction)
                })
            ]
        )
    }

    // MARK: - searchResults Tests

    @Test
    func searchResults_matchesTitle() {
        let recipe = makeRecipe(title: "鶏の照り焼き")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "鶏")

        #expect(results.count == 1)
        #expect(results.first?.matchFields.contains(.title) == true)
    }

    @Test
    func searchResults_matchesDescription() {
        let recipe = makeRecipe(title: "料理", description: "甘辛いタレが美味しい")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "甘辛")

        #expect(results.count == 1)
        #expect(results.first?.matchFields.contains(.description) == true)
    }

    @Test
    func searchResults_matchesIngredientName() {
        let recipe = makeRecipe(title: "料理", ingredientNames: ["鶏もも肉"])
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "鶏もも")

        #expect(results.count == 1)
        #expect(results.first?.matchFields.contains(.ingredients) == true)
    }

    @Test
    func searchResults_matchesStepInstruction() {
        let recipe = makeRecipe(title: "料理", stepInstructions: ["鶏肉を一口大に切る"])
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "一口大")

        #expect(results.count == 1)
        #expect(results.first?.matchFields.contains(.steps) == true)
    }

    @Test
    func searchResults_matchesMultipleFields() {
        let recipe = makeRecipe(
            title: "鶏の照り焼き",
            description: "鶏肉を使った料理",
            ingredientNames: ["鶏もも肉"],
            stepInstructions: ["鶏肉を切る"]
        )
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "鶏")

        #expect(results.count == 1)
        guard let result = results.first else {
            Issue.record("searchResults should not be empty")
            return
        }
        #expect(result.matchFields.contains(.title))
        #expect(result.matchFields.contains(.description))
        #expect(result.matchFields.contains(.ingredients))
        #expect(result.matchFields.contains(.steps))
    }

    @Test
    func searchResults_noMatch_returnsEmpty() {
        let recipe = makeRecipe(title: "カレーライス")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "パスタ")

        #expect(results.isEmpty)
    }

    @Test
    func searchResults_caseInsensitive() {
        let recipe = makeRecipe(title: "Chicken Teriyaki")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "chicken")

        #expect(results.count == 1)
    }

    @Test
    func searchResults_emptyQuery_returnsEmpty() {
        let recipe = makeRecipe(title: "鶏の照り焼き")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "")

        #expect(results.isEmpty)
    }

    @Test
    func searchResults_whitespaceOnlyQuery_returnsEmpty() {
        let recipe = makeRecipe(title: "鶏の照り焼き")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe], query: "   ")

        #expect(results.isEmpty)
    }

    @Test
    func searchResults_multipleRecipes_returnsOnlyMatching() {
        let recipe1 = makeRecipe(title: "鶏の照り焼き")
        let recipe2 = makeRecipe(title: "パスタ")
        let recipe3 = makeRecipe(title: "鶏肉カレー")
        let results = RecipeSearchHelper.searchResults(recipes: [recipe1, recipe2, recipe3], query: "鶏")

        #expect(results.count == 2)
    }

    // MARK: - filteredResults Tests

    @Test
    func filteredResults_withNilCategoryID_returnsAll() {
        let recipe1 = makeRecipe(title: "鶏の照り焼き")
        let recipe2 = makeRecipe(title: "鶏肉カレー")
        let results = [
            RecipeSearchResult(recipe: recipe1, matchFields: .title),
            RecipeSearchResult(recipe: recipe2, matchFields: .title)
        ]

        let filtered = RecipeSearchHelper.filteredResults(results: results, categoryID: nil, categoryRecipeMap: [:])

        #expect(filtered.count == 2)
    }

    @Test
    func filteredResults_withCategoryID_returnsOnlyMatching() {
        let recipe1 = makeRecipe(title: "鶏の照り焼き")
        let recipe2 = makeRecipe(title: "鶏肉カレー")
        let results = [
            RecipeSearchResult(recipe: recipe1, matchFields: .title),
            RecipeSearchResult(recipe: recipe2, matchFields: .title)
        ]
        let categoryID = UUID()
        let map: [UUID: Set<UUID>] = [categoryID: [recipe1.id]]

        let filtered = RecipeSearchHelper.filteredResults(results: results, categoryID: categoryID, categoryRecipeMap: map)

        #expect(filtered.count == 1)
        #expect(filtered.first?.recipe.id == recipe1.id)
    }

    @Test
    func filteredResults_withEmptyCategory_returnsEmpty() {
        let recipe1 = makeRecipe(title: "鶏の照り焼き")
        let results = [RecipeSearchResult(recipe: recipe1, matchFields: .title)]
        let categoryID = UUID()
        let map: [UUID: Set<UUID>] = [categoryID: []]

        let filtered = RecipeSearchHelper.filteredResults(results: results, categoryID: categoryID, categoryRecipeMap: map)

        #expect(filtered.isEmpty)
    }

    // MARK: - categoryCounts Tests

    @Test
    func categoryCounts_returnsCorrectCounts() {
        let recipe1 = makeRecipe(title: "鶏の照り焼き")
        let recipe2 = makeRecipe(title: "鶏肉カレー")
        let recipe3 = makeRecipe(title: "パスタ")
        let results = [
            RecipeSearchResult(recipe: recipe1, matchFields: .title),
            RecipeSearchResult(recipe: recipe2, matchFields: .title)
        ]
        let cat1 = UUID()
        let cat2 = UUID()
        let map: [UUID: Set<UUID>] = [
            cat1: [recipe1.id, recipe3.id],
            cat2: [recipe2.id]
        ]

        let counts = RecipeSearchHelper.categoryCounts(results: results, categoryRecipeMap: map)
        #expect(counts[cat1] == 1)
        #expect(counts[cat2] == 1)
    }

    @Test
    func categoryCounts_withNoResults_returnsZeroCounts() {
        let results: [RecipeSearchResult] = []
        let categoryID = UUID()
        let map: [UUID: Set<UUID>] = [categoryID: [UUID()]]

        let counts = RecipeSearchHelper.categoryCounts(results: results, categoryRecipeMap: map)
        #expect(counts[categoryID] == 0)
    }
}
