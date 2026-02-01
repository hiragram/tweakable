import Foundation
import SwiftData

/// レシピ永続化サービスの実装
public final class RecipePersistenceService: RecipePersistenceServiceProtocol, @unchecked Sendable {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - Recipe Operations

    @MainActor
    public func saveRecipe(_ recipe: Recipe) async throws {
        let context = modelContainer.mainContext

        // 既存のレシピを検索
        let id = recipe.id
        let descriptor = FetchDescriptor<PersistedRecipe>(
            predicate: #Predicate { $0.id == id }
        )
        let existing = try context.fetch(descriptor).first

        if let existing = existing {
            // 既存を更新
            existing.title = recipe.title
            existing.descriptionText = recipe.description
            existing.servings = recipe.ingredientsInfo.servings
            existing.sourceURLString = recipe.sourceURL?.absoluteString
            existing.imageURLStrings = recipe.imageURLs.compactMap { imageSource -> String? in
                if case .remote(let url) = imageSource {
                    return url.absoluteString
                }
                return nil
            }
            existing.updatedAt = Date()

            // 材料を更新
            existing.ingredients.forEach { context.delete($0) }
            existing.ingredients = recipe.ingredientsInfo.items.map { item in
                PersistedIngredient(
                    id: item.id,
                    name: item.name,
                    amount: item.amount,
                    isModified: item.isModified
                )
            }

            // 工程を更新
            existing.steps.forEach { context.delete($0) }
            existing.steps = recipe.steps.map { step in
                let imageURLStrings = step.imageURLs.compactMap { imageSource -> String? in
                    if case .remote(let url) = imageSource {
                        return url.absoluteString
                    }
                    return nil
                }
                return PersistedCookingStep(
                    id: step.id,
                    stepNumber: step.stepNumber,
                    instruction: step.instruction,
                    imageURLStrings: imageURLStrings,
                    isModified: step.isModified
                )
            }
        } else {
            // 新規作成
            _ = PersistedRecipe.from(recipe, context: context)
        }

        try context.save()
    }

    @MainActor
    public func loadRecipe(id: UUID) async throws -> Recipe? {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedRecipe>(
            predicate: #Predicate { $0.id == id }
        )
        guard let persisted = try context.fetch(descriptor).first else {
            return nil
        }
        return persisted.toDomain()
    }

    @MainActor
    public func loadAllRecipes() async throws -> [Recipe] {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedRecipe>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let persisted = try context.fetch(descriptor)
        return persisted.map { $0.toDomain() }
    }

    @MainActor
    public func deleteRecipe(id: UUID) async throws {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedRecipe>(
            predicate: #Predicate { $0.id == id }
        )
        guard let persisted = try context.fetch(descriptor).first else {
            return
        }
        context.delete(persisted)
        try context.save()
    }

    // MARK: - ShoppingList Operations

    @MainActor
    public func createShoppingList(name: String, recipeIDs: [UUID]) async throws -> ShoppingListDTO {
        let context = modelContainer.mainContext

        // レシピを一括取得（N+1問題を回避）
        let allRecipesDescriptor = FetchDescriptor<PersistedRecipe>()
        let allRecipes = try context.fetch(allRecipesDescriptor)
        let recipeIDSet = Set(recipeIDs)
        let recipes = allRecipes.filter { recipeIDSet.contains($0.id) }

        // 買い物リストを作成
        let shoppingList = PersistedShoppingList(
            name: name,
            recipes: recipes
        )
        context.insert(shoppingList)

        // 材料を集約してアイテムを作成
        let aggregatedItems = aggregateIngredients(from: recipes)
        shoppingList.items = aggregatedItems

        try context.save()

        return shoppingListToDTO(shoppingList)
    }

    @MainActor
    public func loadShoppingList(id: UUID) async throws -> ShoppingListDTO? {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedShoppingList>(
            predicate: #Predicate { $0.id == id }
        )
        guard let persisted = try context.fetch(descriptor).first else {
            return nil
        }
        return shoppingListToDTO(persisted)
    }

    @MainActor
    public func loadAllShoppingLists() async throws -> [ShoppingListDTO] {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedShoppingList>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let persisted = try context.fetch(descriptor)
        return persisted.map { shoppingListToDTO($0) }
    }

    @MainActor
    public func addRecipeToShoppingList(listID: UUID, recipeID: UUID) async throws {
        let context = modelContainer.mainContext

        let listDescriptor = FetchDescriptor<PersistedShoppingList>(
            predicate: #Predicate { $0.id == listID }
        )
        guard let list = try context.fetch(listDescriptor).first else { return }

        let recipeDescriptor = FetchDescriptor<PersistedRecipe>(
            predicate: #Predicate { $0.id == recipeID }
        )
        guard let recipe = try context.fetch(recipeDescriptor).first else { return }

        list.recipes.append(recipe)
        list.updatedAt = Date()

        // アイテムを再集約
        list.items.forEach { context.delete($0) }
        list.items = aggregateIngredients(from: list.recipes)

        try context.save()
    }

    @MainActor
    public func removeRecipeFromShoppingList(listID: UUID, recipeID: UUID) async throws {
        let context = modelContainer.mainContext

        let listDescriptor = FetchDescriptor<PersistedShoppingList>(
            predicate: #Predicate { $0.id == listID }
        )
        guard let list = try context.fetch(listDescriptor).first else { return }

        list.recipes.removeAll { $0.id == recipeID }
        list.updatedAt = Date()

        // アイテムを再集約
        list.items.forEach { context.delete($0) }
        list.items = aggregateIngredients(from: list.recipes)

        try context.save()
    }

    @MainActor
    public func deleteShoppingList(id: UUID) async throws {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedShoppingList>(
            predicate: #Predicate { $0.id == id }
        )
        guard let persisted = try context.fetch(descriptor).first else { return }
        context.delete(persisted)
        try context.save()
    }

    @MainActor
    public func updateShoppingItemChecked(itemID: UUID, isChecked: Bool) async throws {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<PersistedShoppingListItem>(
            predicate: #Predicate { $0.id == itemID }
        )
        guard let item = try context.fetch(descriptor).first else { return }
        item.isChecked = isChecked
        try context.save()
    }

    // MARK: - Private Helpers

    /// 複数レシピの材料を集約する
    private func aggregateIngredients(from recipes: [PersistedRecipe]) -> [PersistedShoppingListItem] {
        // 材料名でグループ化
        var ingredientMap: [String: [(amount: String?, recipeID: UUID, recipeTitle: String)]] = [:]

        for recipe in recipes {
            for ingredient in recipe.ingredients {
                let key = ingredient.name.lowercased()
                let entry = (amount: ingredient.amount, recipeID: recipe.id, recipeTitle: recipe.title)
                ingredientMap[key, default: []].append(entry)
            }
        }

        // 集約してアイテムを作成
        return ingredientMap.map { (name, entries) in
            let breakdowns = entries.map { entry in
                PersistedShoppingListItemBreakdown(
                    amount: entry.amount,
                    sourceRecipeID: entry.recipeID,
                    sourceRecipeTitle: entry.recipeTitle
                )
            }

            // 合計量を計算（単純な文字列結合。数値計算は複雑なのでMVPでは省略）
            let totalAmount: String? = if entries.count == 1 {
                entries.first?.amount
            } else {
                entries.compactMap { $0.amount }.joined(separator: " + ")
            }

            return PersistedShoppingListItem(
                name: entries.first?.recipeTitle != nil ? name.capitalized : name,
                totalAmount: totalAmount,
                breakdowns: breakdowns
            )
        }
    }

    // MARK: - Debug Operations

    @MainActor
    public func deleteAllData() async throws {
        let context = modelContainer.mainContext

        // 親モデルを個別に取得して削除（カスケードで子も削除される）
        // ShoppingListを削除するとitemsとbreakdownsもカスケード削除される
        let shoppingLists = try context.fetch(FetchDescriptor<PersistedShoppingList>())
        for list in shoppingLists {
            context.delete(list)
        }

        // Recipeを削除するとingredientsとstepsもカスケード削除される
        let recipes = try context.fetch(FetchDescriptor<PersistedRecipe>())
        for recipe in recipes {
            context.delete(recipe)
        }

        try context.save()
    }

    /// PersistedShoppingListをDTOに変換
    private func shoppingListToDTO(_ list: PersistedShoppingList) -> ShoppingListDTO {
        let itemDTOs = list.items.map { item in
            let breakdownDTOs = item.breakdowns.map { breakdown in
                ShoppingListItemBreakdownDTO(
                    id: breakdown.id,
                    amount: breakdown.amount,
                    sourceRecipeID: breakdown.sourceRecipeID,
                    sourceRecipeTitle: breakdown.sourceRecipeTitle
                )
            }
            return ShoppingListItemDTO(
                id: item.id,
                name: item.name,
                totalAmount: item.totalAmount,
                category: item.category,
                isChecked: item.isChecked,
                breakdowns: breakdownDTOs
            )
        }

        return ShoppingListDTO(
            id: list.id,
            name: list.name,
            createdAt: list.createdAt,
            updatedAt: list.updatedAt,
            recipeIDs: list.recipes.map { $0.id },
            items: itemDTOs
        )
    }
}
