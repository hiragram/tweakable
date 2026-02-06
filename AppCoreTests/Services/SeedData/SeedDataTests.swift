import Testing
@testable import AppCore

@Suite
struct SeedDataTests {

    @Test
    func categoryName_isEitan() {
        #expect(SeedData.categoryName == "Eitan")
    }

    @Test
    func recipes_forJa_returnsJapaneseRecipes() {
        let recipes = SeedData.recipes(for: "ja")

        #expect(recipes.count == SeedData.japaneseRecipes.count)
        #expect(recipes.first?.id == SeedData.japaneseRecipes.first?.id)
    }

    @Test
    func recipes_forEn_returnsEnglishRecipes() {
        let recipes = SeedData.recipes(for: "en")

        #expect(recipes.count == SeedData.englishRecipes.count)
        #expect(recipes.first?.id == SeedData.englishRecipes.first?.id)
    }

    @Test
    func recipes_forUnknownLanguage_returnsEnglishRecipes() {
        let recipes = SeedData.recipes(for: "fr")

        #expect(recipes.count == SeedData.englishRecipes.count)
        #expect(recipes.first?.id == SeedData.englishRecipes.first?.id)
    }

    @Test
    func jaAndEnRecipes_haveMatchingUUIDs() {
        let jaRecipes = SeedData.japaneseRecipes
        let enRecipes = SeedData.englishRecipes

        #expect(jaRecipes.count == enRecipes.count)

        let jaIDs = Set(jaRecipes.map { $0.id })
        let enIDs = Set(enRecipes.map { $0.id })

        #expect(jaIDs == enIDs)
    }

    @Test
    func jaAndEnRecipes_haveExpectedCount() {
        #expect(SeedData.japaneseRecipes.count == 22)
        #expect(SeedData.englishRecipes.count == 22)
    }
}
