import Foundation

// MARK: - RecipeSearchHelper

/// レシピ検索ロジックを純粋関数として提供するヘルパー
public enum RecipeSearchHelper {

    /// レシピ一覧からクエリに一致するものを検索
    public static func searchResults(recipes: [Recipe], query: String) -> [RecipeSearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let lowered = trimmed.lowercased()
        return recipes.compactMap { recipe in
            var matchFields = SearchMatchField()

            if recipe.title.lowercased().contains(lowered) {
                matchFields.insert(.title)
            }
            if let desc = recipe.description, desc.lowercased().contains(lowered) {
                matchFields.insert(.description)
            }
            if recipe.ingredientsInfo.allItems.contains(where: { $0.name.lowercased().contains(lowered) }) {
                matchFields.insert(.ingredients)
            }
            if recipe.allSteps.contains(where: { $0.instruction.lowercased().contains(lowered) }) {
                matchFields.insert(.steps)
            }

            return matchFields.isEmpty ? nil : RecipeSearchResult(recipe: recipe, matchFields: matchFields)
        }
    }

    /// 検索結果にカテゴリフィルタを適用
    public static func filteredResults(
        results: [RecipeSearchResult],
        categoryID: UUID?,
        categoryRecipeMap: [UUID: Set<UUID>]
    ) -> [RecipeSearchResult] {
        guard let categoryID else { return results }
        let recipeIDs = categoryRecipeMap[categoryID] ?? []
        return results.filter { recipeIDs.contains($0.recipe.id) }
    }

    /// 検索結果における各カテゴリの件数を算出
    public static func categoryCounts(
        results: [RecipeSearchResult],
        categoryRecipeMap: [UUID: Set<UUID>]
    ) -> [UUID: Int] {
        let resultIDs = Set(results.map { $0.recipe.id })
        var counts: [UUID: Int] = [:]
        for (categoryID, recipeIDs) in categoryRecipeMap {
            counts[categoryID] = recipeIDs.intersection(resultIDs).count
        }
        return counts
    }
}
