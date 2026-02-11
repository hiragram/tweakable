import Testing
import SwiftData
@testable import AppCore

@Suite
struct PersistedRecipeConverterTests {

    // MARK: - Helper

    /// テスト用のインメモリModelContainerを作成
    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            PersistedRecipe.self,
            PersistedIngredientSection.self,
            PersistedIngredient.self,
            PersistedCookingStepSection.self,
            PersistedCookingStep.self,
            PersistedShoppingList.self,
            PersistedShoppingListItem.self,
            PersistedShoppingListItemBreakdown.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    // MARK: - toDomain Tests

    @Test
    func toDomain_convertsBasicProperties() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let id = UUID()
        let persisted = PersistedRecipe(
            id: id,
            title: "テスト料理",
            descriptionText: "おいしい料理です",
            servings: "4人分",
            sourceURLString: "https://example.com/recipe"
        )
        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.id == id)
        #expect(domain.title == "テスト料理")
        #expect(domain.description == "おいしい料理です")
        #expect(domain.ingredientsInfo.servings == "4人分")
        #expect(domain.sourceURL?.absoluteString == "https://example.com/recipe")
    }

    @Test
    func toDomain_convertsIngredientSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(id: UUID(), title: "テスト")

        // セクションを作成
        let section = PersistedIngredientSection(header: "メイン材料", sortOrder: 0)
        let ingredient1 = PersistedIngredient(name: "鶏肉", amount: "200g", sortOrder: 0)
        let ingredient2 = PersistedIngredient(name: "塩", amount: "小さじ1", isModified: true, sortOrder: 1)
        section.ingredients = [ingredient1, ingredient2]
        persisted.ingredientSections = [section]

        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.ingredientsInfo.sections.count == 1)
        #expect(domain.ingredientsInfo.sections[0].header == "メイン材料")
        #expect(domain.ingredientsInfo.allItems.count == 2)
        #expect(domain.ingredientsInfo.allItems[0].name == "鶏肉")
        #expect(domain.ingredientsInfo.allItems[0].amount == "200g")
        #expect(domain.ingredientsInfo.allItems[0].isModified == false)
        #expect(domain.ingredientsInfo.allItems[1].name == "塩")
        #expect(domain.ingredientsInfo.allItems[1].isModified == true)
    }

    @Test
    func toDomain_convertsCookingStepSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(id: UUID(), title: "テスト")

        // セクションを作成
        let section = PersistedCookingStepSection(header: "下準備", sortOrder: 0)
        let step1 = PersistedCookingStep(stepNumber: 1, instruction: "材料を切る", sortOrder: 0)
        let step2 = PersistedCookingStep(stepNumber: 2, instruction: "炒める", isModified: true, sortOrder: 1)
        section.steps = [step1, step2]
        persisted.stepSections = [section]

        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.stepSections.count == 1)
        #expect(domain.stepSections[0].header == "下準備")
        #expect(domain.allSteps.count == 2)
        #expect(domain.allSteps[0].stepNumber == 1)
        #expect(domain.allSteps[0].instruction == "材料を切る")
        #expect(domain.allSteps[1].stepNumber == 2)
        #expect(domain.allSteps[1].isModified == true)
    }

    @Test
    func toDomain_convertsImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(
            id: UUID(),
            title: "テスト",
            imageURLStrings: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"]
        )
        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.imageURLs.count == 2)
        if case .remote(let url) = domain.imageURLs[0] {
            #expect(url.absoluteString == "https://example.com/image1.jpg")
        } else {
            Issue.record("Expected .remote case")
        }
    }

    @Test
    func toDomain_convertsBundledImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(
            id: UUID(),
            title: "テスト",
            imageURLStrings: ["bundled://seed-shakshuka"]
        )
        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.imageURLs.count == 1)
        if case .bundled(let name) = domain.imageURLs[0] {
            #expect(name == "seed-shakshuka")
        } else {
            Issue.record("Expected .bundled case")
        }
    }

    @Test
    func toDomain_convertsMixedImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(
            id: UUID(),
            title: "テスト",
            imageURLStrings: [
                "bundled://seed-shakshuka",
                "https://example.com/image.jpg"
            ]
        )
        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.imageURLs.count == 2)
        if case .bundled(let name) = domain.imageURLs[0] {
            #expect(name == "seed-shakshuka")
        } else {
            Issue.record("Expected .bundled case for first image")
        }
        if case .remote(let url) = domain.imageURLs[1] {
            #expect(url.absoluteString == "https://example.com/image.jpg")
        } else {
            Issue.record("Expected .remote case for second image")
        }
    }

    // MARK: - from Domain Tests

    @Test
    @MainActor
    func fromDomain_convertsBasicProperties() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let id = UUID()
        let domain = Recipe(
            id: id,
            title: "ドメインレシピ",
            description: "説明文",
            ingredientsInfo: Ingredients(servings: "2人分", sections: []),
            stepSections: [],
            sourceURL: URL(string: "https://example.com/recipe")
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        #expect(persisted.id == id)
        #expect(persisted.title == "ドメインレシピ")
        #expect(persisted.descriptionText == "説明文")
        #expect(persisted.servings == "2人分")
        #expect(persisted.sourceURLString == "https://example.com/recipe")
    }

    @Test
    @MainActor
    func fromDomain_convertsIngredientSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let ingredients = Ingredients(
            servings: nil,
            sections: [
                IngredientSection(header: "野菜", items: [
                    Ingredient(name: "玉ねぎ", amount: "1個"),
                    Ingredient(name: "にんにく", amount: "2片", isModified: true)
                ])
            ]
        )
        let domain = Recipe(
            id: UUID(),
            title: "テスト",
            ingredientsInfo: ingredients,
            stepSections: []
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        #expect(persisted.ingredientSections.count == 1)
        #expect(persisted.ingredientSections[0].header == "野菜")
        #expect(persisted.ingredientSections[0].ingredients.count == 2)
        #expect(persisted.ingredientSections[0].ingredients[0].name == "玉ねぎ")
        #expect(persisted.ingredientSections[0].ingredients[0].amount == "1個")
        #expect(persisted.ingredientSections[0].ingredients[1].name == "にんにく")
        #expect(persisted.ingredientSections[0].ingredients[1].isModified == true)
    }

    @Test
    @MainActor
    func fromDomain_convertsCookingStepSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let domain = Recipe(
            id: UUID(),
            title: "テスト",
            ingredientsInfo: Ingredients(sections: []),
            stepSections: [
                CookingStepSection(header: "調理", items: [
                    CookingStep(stepNumber: 1, instruction: "下準備"),
                    CookingStep(stepNumber: 2, instruction: "調理", isModified: true)
                ])
            ]
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        #expect(persisted.stepSections.count == 1)
        #expect(persisted.stepSections[0].header == "調理")
        #expect(persisted.stepSections[0].steps.count == 2)
        #expect(persisted.stepSections[0].steps[0].stepNumber == 1)
        #expect(persisted.stepSections[0].steps[0].instruction == "下準備")
        #expect(persisted.stepSections[0].steps[1].stepNumber == 2)
        #expect(persisted.stepSections[0].steps[1].isModified == true)
    }

    @Test
    @MainActor
    func fromDomain_convertsRemoteImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let domain = Recipe(
            id: UUID(),
            title: "テスト",
            imageURLs: [
                .remote(url: URL(string: "https://example.com/a.jpg")!),
                .remote(url: URL(string: "https://example.com/b.jpg")!)
            ],
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        #expect(persisted.imageURLStrings.count == 2)
        #expect(persisted.imageURLStrings[0] == "https://example.com/a.jpg")
        #expect(persisted.imageURLStrings[1] == "https://example.com/b.jpg")
    }

    @Test
    @MainActor
    func fromDomain_ignoresNonRemoteImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let domain = Recipe(
            id: UUID(),
            title: "テスト",
            imageURLs: [
                .remote(url: URL(string: "https://example.com/a.jpg")!),
                .local(fileURL: URL(fileURLWithPath: "/tmp/local.jpg")),
                .uiImage(UIImage())
            ],
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        // リモートURLのみ保存される
        #expect(persisted.imageURLStrings.count == 1)
        #expect(persisted.imageURLStrings[0] == "https://example.com/a.jpg")
    }

    @Test
    @MainActor
    func fromDomain_convertsBundledImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let domain = Recipe(
            id: UUID(),
            title: "テスト",
            imageURLs: [.bundled(name: "seed-shakshuka")],
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        #expect(persisted.imageURLStrings.count == 1)
        #expect(persisted.imageURLStrings[0] == "bundled://seed-shakshuka")
    }

    @Test
    @MainActor
    func fromDomain_convertsMixedImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let domain = Recipe(
            id: UUID(),
            title: "テスト",
            imageURLs: [
                .bundled(name: "seed-shakshuka"),
                .remote(url: URL(string: "https://example.com/a.jpg")!),
                .local(fileURL: URL(fileURLWithPath: "/tmp/local.jpg")),
                .uiImage(UIImage())
            ],
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )

        let persisted = PersistedRecipe.from(domain, context: context)

        // bundledとremoteのみ保存される
        #expect(persisted.imageURLStrings.count == 2)
        #expect(persisted.imageURLStrings[0] == "bundled://seed-shakshuka")
        #expect(persisted.imageURLStrings[1] == "https://example.com/a.jpg")
    }

    @Test
    @MainActor
    func roundTrip_preservesBundledImageURLs() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let original = Recipe(
            id: UUID(),
            title: "バンドル画像テスト",
            imageURLs: [.bundled(name: "seed-chicken-tikka")],
            ingredientsInfo: Ingredients(sections: []),
            stepSections: []
        )

        // Domain -> Persisted -> Domain
        let persisted = PersistedRecipe.from(original, context: context)
        let restored = persisted.toDomain()

        #expect(restored.imageURLs.count == 1)
        if case .bundled(let name) = restored.imageURLs[0] {
            #expect(name == "seed-chicken-tikka")
        } else {
            Issue.record("Expected .bundled case after round trip")
        }
    }

    // MARK: - Multiple Sections Tests

    @Test
    func toDomain_convertsMultipleIngredientSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(id: UUID(), title: "ピザ")

        let doughSection = PersistedIngredientSection(header: "For the Dough", sortOrder: 0)
        doughSection.ingredients = [
            PersistedIngredient(name: "小麦粉", amount: "200g", sortOrder: 0),
            PersistedIngredient(name: "水", amount: "100ml", sortOrder: 1)
        ]

        let sauceSection = PersistedIngredientSection(header: "For the Sauce", sortOrder: 1)
        sauceSection.ingredients = [
            PersistedIngredient(name: "トマト", amount: "3個", sortOrder: 0)
        ]

        // 逆順で挿入してsortOrderで正しくソートされることを検証
        persisted.ingredientSections = [sauceSection, doughSection]

        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.ingredientsInfo.sections.count == 2)
        #expect(domain.ingredientsInfo.sections[0].header == "For the Dough")
        #expect(domain.ingredientsInfo.sections[0].items.count == 2)
        #expect(domain.ingredientsInfo.sections[0].items[0].name == "小麦粉")
        #expect(domain.ingredientsInfo.sections[0].items[1].name == "水")
        #expect(domain.ingredientsInfo.sections[1].header == "For the Sauce")
        #expect(domain.ingredientsInfo.sections[1].items.count == 1)
        #expect(domain.ingredientsInfo.allItems.count == 3)
    }

    @Test
    func toDomain_convertsMultipleCookingStepSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let persisted = PersistedRecipe(id: UUID(), title: "ピザ")

        let prepSection = PersistedCookingStepSection(header: "下準備", sortOrder: 0)
        prepSection.steps = [
            PersistedCookingStep(stepNumber: 1, instruction: "生地をこねる", sortOrder: 0),
            PersistedCookingStep(stepNumber: 2, instruction: "30分寝かせる", sortOrder: 1)
        ]

        let cookSection = PersistedCookingStepSection(header: "焼き上げ", sortOrder: 1)
        cookSection.steps = [
            PersistedCookingStep(stepNumber: 3, instruction: "オーブンで焼く", sortOrder: 0)
        ]

        // 逆順で挿入してsortOrderで正しくソートされることを検証
        persisted.stepSections = [cookSection, prepSection]

        context.insert(persisted)

        let domain = persisted.toDomain()

        #expect(domain.stepSections.count == 2)
        #expect(domain.stepSections[0].header == "下準備")
        #expect(domain.stepSections[0].items.count == 2)
        #expect(domain.stepSections[0].items[0].instruction == "生地をこねる")
        #expect(domain.stepSections[0].items[1].instruction == "30分寝かせる")
        #expect(domain.stepSections[1].header == "焼き上げ")
        #expect(domain.stepSections[1].items.count == 1)
        #expect(domain.allSteps.count == 3)
    }

    @Test
    @MainActor
    func roundTrip_preservesMultipleSections() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let original = Recipe(
            id: UUID(),
            title: "カプレーゼピザ",
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(header: "For the Dough", items: [
                        Ingredient(name: "小麦粉", amount: "200g"),
                        Ingredient(name: "水", amount: "100ml")
                    ]),
                    IngredientSection(header: "For the Sauce", items: [
                        Ingredient(name: "トマト", amount: "3個")
                    ]),
                    IngredientSection(header: "For the Topping", items: [
                        Ingredient(name: "モッツァレラ", amount: "1個"),
                        Ingredient(name: "バジル", amount: "適量")
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(header: "生地", items: [
                    CookingStep(stepNumber: 1, instruction: "生地をこねる")
                ]),
                CookingStepSection(header: "焼き上げ", items: [
                    CookingStep(stepNumber: 2, instruction: "オーブンで焼く")
                ])
            ]
        )

        let persisted = PersistedRecipe.from(original, context: context)
        let restored = persisted.toDomain()

        #expect(restored.ingredientsInfo.sections.count == 3)
        #expect(restored.ingredientsInfo.sections[0].header == "For the Dough")
        #expect(restored.ingredientsInfo.sections[0].items.count == 2)
        #expect(restored.ingredientsInfo.sections[1].header == "For the Sauce")
        #expect(restored.ingredientsInfo.sections[1].items.count == 1)
        #expect(restored.ingredientsInfo.sections[2].header == "For the Topping")
        #expect(restored.ingredientsInfo.sections[2].items.count == 2)
        #expect(restored.ingredientsInfo.allItems.count == 5)

        #expect(restored.stepSections.count == 2)
        #expect(restored.stepSections[0].header == "生地")
        #expect(restored.stepSections[1].header == "焼き上げ")
        #expect(restored.allSteps.count == 2)
    }

    // MARK: - Round Trip Tests

    @Test
    @MainActor
    func roundTrip_preservesData() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let originalID = UUID()
        let original = Recipe(
            id: originalID,
            title: "往復テスト",
            description: "説明",
            imageURLs: [.remote(url: URL(string: "https://example.com/img.jpg")!)],
            ingredientsInfo: Ingredients(
                servings: "3人分",
                sections: [
                    IngredientSection(header: "メイン", items: [
                        Ingredient(name: "豚肉", amount: "300g", isModified: false),
                        Ingredient(name: "醤油", amount: "大さじ2", isModified: true)
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(header: "調理工程", items: [
                    CookingStep(stepNumber: 1, instruction: "切る"),
                    CookingStep(stepNumber: 2, instruction: "焼く", isModified: true)
                ])
            ],
            sourceURL: URL(string: "https://example.com/recipe")
        )

        // Domain -> Persisted -> Domain
        let persisted = PersistedRecipe.from(original, context: context)
        let restored = persisted.toDomain()

        #expect(restored.id == original.id)
        #expect(restored.title == original.title)
        #expect(restored.description == original.description)
        #expect(restored.ingredientsInfo.servings == original.ingredientsInfo.servings)
        #expect(restored.ingredientsInfo.sections.count == original.ingredientsInfo.sections.count)
        #expect(restored.ingredientsInfo.allItems.count == original.ingredientsInfo.allItems.count)
        #expect(restored.stepSections.count == original.stepSections.count)
        #expect(restored.allSteps.count == original.allSteps.count)
        #expect(restored.sourceURL == original.sourceURL)
    }
}
