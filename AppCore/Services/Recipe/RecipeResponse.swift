import Foundation
import OpenAI

/// OpenAI APIからのレスポンス用中間モデル
/// JSONSchemaConvertibleに準拠してStructured Outputsを使用
public struct RecipeResponse: Codable, Sendable, JSONSchemaConvertible {
    public let title: String
    public let description: String?
    public let imageURLs: [String]
    public let servings: String?
    public let ingredients: [IngredientResponse]
    public let steps: [StepResponse]

    public struct IngredientResponse: Codable, Sendable, JSONSchemaConvertible {
        public let name: String
        public let amount: String?
        public let isModified: Bool?

        public init(name: String, amount: String? = nil, isModified: Bool? = nil) {
            self.name = name
            self.amount = amount
            self.isModified = isModified
        }

        public static let example = IngredientResponse(name: "玉ねぎ", amount: "2個", isModified: false)
    }

    public struct StepResponse: Codable, Sendable, JSONSchemaConvertible {
        public let stepNumber: Int
        public let instruction: String
        public let imageURLs: [String]?
        public let isModified: Bool?

        public init(stepNumber: Int, instruction: String, imageURLs: [String]? = nil, isModified: Bool? = nil) {
            self.stepNumber = stepNumber
            self.instruction = instruction
            self.imageURLs = imageURLs
            self.isModified = isModified
        }

        public static let example = StepResponse(stepNumber: 1, instruction: "野菜を切る", imageURLs: ["https://example.com/step1.jpg"], isModified: false)
    }

    // JSONSchemaConvertibleの要件
    // 注意: exampleではすべてのオプショナルプロパティに値を設定する必要がある（nilは不可）
    public static let example = RecipeResponse(
        title: "カレーライス",
        description: "家庭の定番カレー",
        imageURLs: ["https://example.com/curry.jpg"],
        servings: "4人分",
        ingredients: [
            IngredientResponse.example
        ],
        steps: [
            StepResponse.example
        ]
    )
}

// MARK: - Recipe変換

extension RecipeResponse {
    /// RecipeResponseをRecipeモデルに変換
    func toRecipe(sourceURL: URL) -> Recipe {
        Recipe(
            title: title,
            description: description,
            imageURLs: imageURLs.compactMap { URL(string: $0) },
            ingredientsInfo: Ingredients(
                servings: servings,
                items: ingredients.map {
                    Ingredient(name: $0.name, amount: $0.amount, isModified: $0.isModified ?? false)
                }
            ),
            steps: steps.map {
                CookingStep(
                    stepNumber: $0.stepNumber,
                    instruction: $0.instruction,
                    imageURLs: $0.imageURLs?.compactMap { URL(string: $0) } ?? [],
                    isModified: $0.isModified ?? false
                )
            },
            sourceURL: sourceURL
        )
    }
}
