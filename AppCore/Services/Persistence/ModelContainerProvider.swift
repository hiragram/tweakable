import Foundation
import SwiftData

/// SwiftDataのModelContainerを提供するユーティリティ
public enum ModelContainerProvider {
    /// アプリ用のスキーマ
    public static var schema: Schema {
        Schema([
            PersistedRecipe.self,
            PersistedIngredient.self,
            PersistedCookingStep.self,
            PersistedShoppingList.self,
            PersistedShoppingListItem.self,
            PersistedShoppingListItemBreakdown.self,
            PersistedRecipeCategory.self
        ])
    }

    /// 本番用のModelContainer（永続化あり）
    public static func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(schema: schema)
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// テスト用のModelContainer（インメモリ）
    public static func makeInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
