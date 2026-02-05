import Foundation

/// UIテスト用のモックレシピ抽出サービス
public struct MockRecipeExtractionService: RecipeExtractionServiceProtocol, Sendable {

    /// モックの動作モード
    ///
    /// UIテストでサービスの動作を制御するために使用する。
    /// アプリの起動引数（`--mock-extraction-error` など）と連携して、
    /// 特定のエラーシナリオをテスト可能にする。
    public enum MockBehavior: Sendable {
        /// 正常動作 - レシピ抽出・置き換えとも成功
        case success
        /// レシピ抽出時にエラーを発生させる
        case extractionError
        /// 置き換え時にエラーを発生させる（抽出は成功）
        case substitutionError
    }

    /// モック用エラー
    public enum MockError: Error, LocalizedError {
        case extractionFailed
        case substitutionFailed

        public var errorDescription: String? {
            switch self {
            case .extractionFailed:
                return "レシピの抽出に失敗しました（モックエラー）"
            case .substitutionFailed:
                return "置き換えに失敗しました（モックエラー）"
            }
        }
    }

    private let behavior: MockBehavior

    /// テスト用の固定レシピ
    public static let mockRecipe = Recipe(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "テスト用チキンカレー",
        description: "UIテスト用のサンプルレシピです。スパイシーで美味しいチキンカレーの作り方。",
        imageURLs: [],
        ingredientsInfo: Ingredients(
            servings: "2人分",
            sections: [
                IngredientSection(items: [
                    Ingredient(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
                        name: "鶏もも肉",
                        amount: "300g",
                        isModified: false
                    ),
                    Ingredient(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
                        name: "玉ねぎ",
                        amount: "1個",
                        isModified: false
                    ),
                    Ingredient(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
                        name: "カレールー",
                        amount: "4皿分",
                        isModified: false
                    ),
                    Ingredient(
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
                        name: "水",
                        amount: "400ml",
                        isModified: false
                    )
                ])
            ]
        ),
        stepSections: [
            CookingStepSection(items: [
                CookingStep(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
                    stepNumber: 1,
                    instruction: "鶏もも肉を一口大に切り、玉ねぎは薄切りにする。",
                    imageURLs: [],
                    isModified: false
                ),
                CookingStep(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
                    stepNumber: 2,
                    instruction: "鍋に油を熱し、鶏肉を炒める。表面に焼き色がついたら玉ねぎを加えて炒める。",
                    imageURLs: [],
                    isModified: false
                ),
                CookingStep(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
                    stepNumber: 3,
                    instruction: "水を加えて沸騰したらアクを取り、弱火で15分煮込む。",
                    imageURLs: [],
                    isModified: false
                ),
                CookingStep(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000023")!,
                    stepNumber: 4,
                    instruction: "火を止めてカレールーを溶かし、再び弱火で5分煮込む。",
                    imageURLs: [],
                    isModified: false
                )
            ])
        ],
        sourceURL: URL(string: "https://example.com/test-recipe")
    )

    public init(behavior: MockBehavior = .success) {
        self.behavior = behavior
    }

    public func extractRecipe(from url: URL) async throws -> Recipe {
        // 少し遅延を入れてローディング状態をテスト可能にする
        try await Task.sleep(for: .milliseconds(500))

        if behavior == .extractionError {
            throw MockError.extractionFailed
        }

        return Self.mockRecipe
    }

    public func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String
    ) async throws -> Recipe {
        // 少し遅延を入れてローディング状態をテスト可能にする
        try await Task.sleep(for: .milliseconds(500))

        if behavior == .substitutionError {
            throw MockError.substitutionFailed
        }

        var updatedRecipe = recipe

        switch target {
        case .ingredient(let ingredient):
            // 材料を置き換え済みとしてマーク
            for sectionIndex in updatedRecipe.ingredientsInfo.sections.indices {
                if let itemIndex = updatedRecipe.ingredientsInfo.sections[sectionIndex].items.firstIndex(where: { $0.id == ingredient.id }) {
                    var modifiedIngredient = updatedRecipe.ingredientsInfo.sections[sectionIndex].items[itemIndex]
                    modifiedIngredient = Ingredient(
                        id: modifiedIngredient.id,
                        name: "置き換え済み: \(modifiedIngredient.name)",
                        amount: modifiedIngredient.amount,
                        isModified: true
                    )
                    updatedRecipe.ingredientsInfo.sections[sectionIndex].items[itemIndex] = modifiedIngredient
                    break
                }
            }

        case .step(let step):
            // 工程を置き換え済みとしてマーク
            for sectionIndex in updatedRecipe.stepSections.indices {
                if let itemIndex = updatedRecipe.stepSections[sectionIndex].items.firstIndex(where: { $0.id == step.id }) {
                    var modifiedStep = updatedRecipe.stepSections[sectionIndex].items[itemIndex]
                    modifiedStep = CookingStep(
                        id: modifiedStep.id,
                        stepNumber: modifiedStep.stepNumber,
                        instruction: "置き換え済み: \(modifiedStep.instruction)",
                        imageURLs: modifiedStep.imageURLs,
                        isModified: true
                    )
                    updatedRecipe.stepSections[sectionIndex].items[itemIndex] = modifiedStep
                    break
                }
            }
        }

        return updatedRecipe
    }
}
