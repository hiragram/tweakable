import Foundation
import OpenAI

/// OpenAI APIからのレスポンス用中間モデル
/// JSONSchemaConvertibleに準拠してStructured Outputsを使用
public struct RecipeResponse: Codable, Sendable, JSONSchemaConvertible {
    public let title: String
    public let description: String?
    public let imageURLs: [String]
    public let servings: String?
    public let ingredientSections: [IngredientSectionResponse]
    public let stepSections: [StepSectionResponse]

    // MARK: - IngredientSectionResponse

    public struct IngredientSectionResponse: Codable, Sendable, JSONSchemaConvertible {
        /// セクションのUUID（置き換え時にIDを保持するため）
        public let id: String?
        /// セクション見出し（nilの場合は見出しなしで表示）
        public let header: String?
        /// このセクションの材料リスト
        public let ingredients: [IngredientResponse]

        public init(id: String? = nil, header: String? = nil, ingredients: [IngredientResponse]) {
            self.id = id
            self.header = header
            self.ingredients = ingredients
        }

        public static let example = IngredientSectionResponse(
            id: "550e8400-e29b-41d4-a716-446655440010",
            header: "For the Dough",
            ingredients: [IngredientResponse.example]
        )
    }

    // MARK: - IngredientResponse

    public struct IngredientResponse: Codable, Sendable, JSONSchemaConvertible {
        /// 食材のUUID（置き換え時にIDを保持するため）
        public let id: String?
        public let name: String
        public let amount: String?
        public let isModified: Bool?

        public init(id: String? = nil, name: String, amount: String? = nil, isModified: Bool? = nil) {
            self.id = id
            self.name = name
            self.amount = amount
            self.isModified = isModified
        }

        public static let example = IngredientResponse(
            id: "550e8400-e29b-41d4-a716-446655440000",
            name: "玉ねぎ",
            amount: "2個",
            isModified: false
        )
    }

    // MARK: - StepSectionResponse

    public struct StepSectionResponse: Codable, Sendable, JSONSchemaConvertible {
        /// セクションのUUID（置き換え時にIDを保持するため）
        public let id: String?
        /// セクション見出し（nilの場合は見出しなしで表示）
        public let header: String?
        /// このセクションの調理工程リスト
        public let steps: [StepResponse]

        public init(id: String? = nil, header: String? = nil, steps: [StepResponse]) {
            self.id = id
            self.header = header
            self.steps = steps
        }

        public static let example = StepSectionResponse(
            id: "550e8400-e29b-41d4-a716-446655440020",
            header: "For the Dough",
            steps: [StepResponse.example]
        )
    }

    // MARK: - StepResponse

    public struct StepResponse: Codable, Sendable, JSONSchemaConvertible {
        /// 工程のUUID（置き換え時にIDを保持するため）
        public let id: String?
        public let stepNumber: Int
        public let instruction: String
        public let imageURLs: [String]?
        public let isModified: Bool?

        public init(
            id: String? = nil,
            stepNumber: Int,
            instruction: String,
            imageURLs: [String]? = nil,
            isModified: Bool? = nil
        ) {
            self.id = id
            self.stepNumber = stepNumber
            self.instruction = instruction
            self.imageURLs = imageURLs
            self.isModified = isModified
        }

        public static let example = StepResponse(
            id: "550e8400-e29b-41d4-a716-446655440001",
            stepNumber: 1,
            instruction: "野菜を切る",
            imageURLs: ["https://example.com/step1.jpg"],
            isModified: false
        )
    }

    // JSONSchemaConvertibleの要件
    // 注意: exampleではすべてのオプショナルプロパティに値を設定する必要がある（nilは不可）
    public static let example = RecipeResponse(
        title: "カレーライス",
        description: "家庭の定番カレー",
        imageURLs: ["https://example.com/curry.jpg"],
        servings: "4人分",
        ingredientSections: [
            IngredientSectionResponse.example
        ],
        stepSections: [
            StepSectionResponse.example
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
            imageURLs: imageURLs.compactMap { URL(string: $0) }.map { .remote(url: $0) },
            ingredientsInfo: Ingredients(
                servings: servings,
                sections: ingredientSections.map { section in
                    IngredientSection(
                        id: section.id.flatMap { UUID(uuidString: $0) } ?? UUID(),
                        header: section.header,
                        items: section.ingredients.map { ingredient in
                            Ingredient(
                                id: ingredient.id.flatMap { UUID(uuidString: $0) } ?? UUID(),
                                name: ingredient.name,
                                amount: ingredient.amount,
                                isModified: ingredient.isModified ?? false
                            )
                        }
                    )
                }
            ),
            stepSections: stepSections.map { section in
                CookingStepSection(
                    id: section.id.flatMap { UUID(uuidString: $0) } ?? UUID(),
                    header: section.header,
                    items: section.steps.map { step in
                        CookingStep(
                            id: step.id.flatMap { UUID(uuidString: $0) } ?? UUID(),
                            stepNumber: step.stepNumber,
                            instruction: step.instruction,
                            imageURLs: step.imageURLs?.compactMap { URL(string: $0) }.map { .remote(url: $0) } ?? [],
                            isModified: step.isModified ?? false
                        )
                    }
                )
            },
            sourceURL: sourceURL
        )
    }
}
