import Foundation
import os

private let logger = Logger(subsystem: "com.tweakable.app", category: "SeedData")

/// シードデータ投入サービス
public final class SeedDataService: @unchecked Sendable {
    private let persistenceService: any RecipePersistenceServiceProtocol

    /// UserDefaultsキー
    private static let hasSeedDataLoadedKey = "hasSeedDataLoaded"

    public init(persistenceService: any RecipePersistenceServiceProtocol) {
        self.persistenceService = persistenceService
    }

    /// シードデータが投入済みかどうか
    public var hasSeedDataLoaded: Bool {
        UserDefaults.standard.bool(forKey: Self.hasSeedDataLoadedKey)
    }

    /// シードデータを投入する（未投入の場合のみ）
    @MainActor
    public func seedIfNeeded() async {
        guard !hasSeedDataLoaded else {
            logger.debug("Seed data already loaded, skipping")
            return
        }

        logger.info("Starting seed data injection")

        do {
            // 既存の "Eitan" カテゴリを確認、なければ作成
            let existingCategories = try await persistenceService.loadAllCategories()
            let category: RecipeCategory
            if let existing = existingCategories.categories.first(where: { $0.name == SeedData.categoryName }) {
                category = existing
                logger.debug("Found existing '\(SeedData.categoryName)' category")
            } else {
                category = try await persistenceService.createCategory(name: SeedData.categoryName)
                logger.debug("Created '\(SeedData.categoryName)' category")
            }

            // レシピを保存し、カテゴリに紐付ける
            let recipes = SeedData.recipes()
            for recipe in recipes {
                try await persistenceService.saveRecipe(recipe)
                try await persistenceService.addRecipeToCategory(
                    recipeID: recipe.id,
                    categoryID: category.id
                )
            }

            // フラグを更新
            UserDefaults.standard.set(true, forKey: Self.hasSeedDataLoadedKey)
            logger.info("Seed data injection completed: \(recipes.count) recipes")
        } catch {
            // シードデータ投入失敗はクリティカルではない
            // 次回起動時に再試行される
            logger.error("Failed to seed data: \(error.localizedDescription)")
        }
    }

    #if DEBUG
    /// デバッグ用: シードデータフラグをリセットする
    public static func resetSeedFlag() {
        UserDefaults.standard.removeObject(forKey: hasSeedDataLoadedKey)
        logger.info("Seed data flag reset")
    }
    #endif
}
