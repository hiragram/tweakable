import Foundation
import SwiftData
import UIKit

/// 永続化用のレシピモデル
@Model
public final class PersistedRecipe {
    /// 一意識別子
    @Attribute(.unique)
    public var id: UUID

    /// レシピ名
    public var title: String

    /// 説明文
    public var descriptionText: String?

    /// 何人分か（例: "4人分"）
    public var servings: String?

    /// 元のレシピURL
    public var sourceURLString: String?

    /// 画像URL（JSON文字列として保存）
    /// SwiftDataはenumの配列を直接扱えないため、URL文字列の配列として保存
    public var imageURLStrings: [String]

    /// 作成日時
    public var createdAt: Date

    /// 更新日時
    public var updatedAt: Date

    /// 材料リスト
    @Relationship(deleteRule: .cascade, inverse: \PersistedIngredient.recipe)
    public var ingredients: [PersistedIngredient]

    /// 調理工程
    @Relationship(deleteRule: .cascade, inverse: \PersistedCookingStep.recipe)
    public var steps: [PersistedCookingStep]

    /// 買い物リストとの関連（多対多）
    @Relationship(inverse: \PersistedShoppingList.recipes)
    public var shoppingLists: [PersistedShoppingList]

    public init(
        id: UUID = UUID(),
        title: String,
        descriptionText: String? = nil,
        servings: String? = nil,
        sourceURLString: String? = nil,
        imageURLStrings: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        ingredients: [PersistedIngredient] = [],
        steps: [PersistedCookingStep] = []
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.servings = servings
        self.sourceURLString = sourceURLString
        self.imageURLStrings = imageURLStrings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ingredients = ingredients
        self.steps = steps
        self.shoppingLists = []
    }
}

// MARK: - Domain Conversion

extension PersistedRecipe {
    /// 永続化モデルからドメインモデルへ変換
    public func toDomain() -> Recipe {
        // 材料を変換
        let domainIngredients = ingredients.map { persisted in
            Ingredient(
                id: persisted.id,
                name: persisted.name,
                amount: persisted.amount,
                isModified: persisted.isModified
            )
        }

        // 調理工程を変換
        let domainSteps = steps.map { persisted in
            let stepImageURLs: [ImageSource] = persisted.imageURLStrings.compactMap { urlString in
                guard let url = URL(string: urlString) else { return nil }
                return .remote(url: url)
            }
            return CookingStep(
                id: persisted.id,
                stepNumber: persisted.stepNumber,
                instruction: persisted.instruction,
                imageURLs: stepImageURLs,
                isModified: persisted.isModified
            )
        }

        // 画像URLを変換
        let domainImageURLs: [ImageSource] = imageURLStrings.compactMap { urlString in
            guard let url = URL(string: urlString) else { return nil }
            return .remote(url: url)
        }

        // ソースURLを変換
        let sourceURL: URL? = sourceURLString.flatMap { URL(string: $0) }

        return Recipe(
            id: id,
            title: title,
            description: descriptionText,
            imageURLs: domainImageURLs,
            ingredientsInfo: Ingredients(
                servings: servings,
                items: domainIngredients
            ),
            steps: domainSteps,
            sourceURL: sourceURL
        )
    }

    /// ドメインモデルから永続化モデルへ変換
    @MainActor
    public static func from(_ recipe: Recipe, context: ModelContext) -> PersistedRecipe {
        // 材料を変換
        let persistedIngredients = recipe.ingredientsInfo.items.map { item in
            PersistedIngredient(
                id: item.id,
                name: item.name,
                amount: item.amount,
                isModified: item.isModified
            )
        }

        // 調理工程を変換
        let persistedSteps = recipe.steps.map { step in
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

        // 画像URLを変換（リモートURLのみ）
        let imageURLStrings = recipe.imageURLs.compactMap { imageSource -> String? in
            if case .remote(let url) = imageSource {
                return url.absoluteString
            }
            return nil
        }

        let persisted = PersistedRecipe(
            id: recipe.id,
            title: recipe.title,
            descriptionText: recipe.description,
            servings: recipe.ingredientsInfo.servings,
            sourceURLString: recipe.sourceURL?.absoluteString,
            imageURLStrings: imageURLStrings,
            ingredients: persistedIngredients,
            steps: persistedSteps
        )

        context.insert(persisted)
        return persisted
    }
}
