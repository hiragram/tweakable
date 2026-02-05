import Testing
import Foundation
@testable import AppCore

@Suite(.serialized)
struct SeedDataServiceTests {
    /// テスト専用のUserDefaultsを作成してテスト間の干渉を防ぐ
    private func makeTestDefaults() -> UserDefaults {
        let suiteName = "SeedDataServiceTests-\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    @Test
    func seedIfNeeded_whenAlreadyLoaded_skipsSeeding() async {
        let defaults = makeTestDefaults()
        defaults.set(true, forKey: SeedDataService.hasSeedDataLoadedKey)
        let mockPersistence = MockRecipePersistenceService()
        let service = SeedDataService(persistenceService: mockPersistence, userDefaults: defaults)

        await service.seedIfNeeded()

        #expect(mockPersistence.saveRecipeCallCount == 0)
        #expect(mockPersistence.createCategoryCallCount == 0)
    }

    @Test
    func seedIfNeeded_whenNotLoaded_createsCategoryAndSavesRecipes() async {
        let defaults = makeTestDefaults()
        let mockPersistence = MockRecipePersistenceService()
        let service = SeedDataService(persistenceService: mockPersistence, userDefaults: defaults)

        await service.seedIfNeeded()

        #expect(mockPersistence.createCategoryCallCount == 1)
        #expect(mockPersistence.saveRecipeCallCount > 0)
        #expect(mockPersistence.addRecipeToCategoryCallCount > 0)
    }

    @Test
    func seedIfNeeded_whenNotLoaded_setsFlagAfterCompletion() async {
        let defaults = makeTestDefaults()
        let mockPersistence = MockRecipePersistenceService()
        let service = SeedDataService(persistenceService: mockPersistence, userDefaults: defaults)

        await service.seedIfNeeded()

        #expect(defaults.bool(forKey: SeedDataService.hasSeedDataLoadedKey) == true)
    }

    @Test
    func seedIfNeeded_whenPersistenceFails_doesNotSetFlag() async {
        let defaults = makeTestDefaults()
        let mockPersistence = MockRecipePersistenceService()
        mockPersistence.errorToThrow = NSError(domain: "test", code: 1)
        let service = SeedDataService(persistenceService: mockPersistence, userDefaults: defaults)

        await service.seedIfNeeded()

        #expect(defaults.bool(forKey: SeedDataService.hasSeedDataLoadedKey) == false)
    }

    @Test
    func seedIfNeeded_whenCategoryExists_reusesExistingCategory() async {
        let defaults = makeTestDefaults()
        let mockPersistence = MockRecipePersistenceService()
        let existingCategory = RecipeCategory(name: SeedData.categoryName)
        mockPersistence.categories[existingCategory.id] = existingCategory
        let service = SeedDataService(persistenceService: mockPersistence, userDefaults: defaults)

        await service.seedIfNeeded()

        #expect(mockPersistence.createCategoryCallCount == 0)
        #expect(mockPersistence.saveRecipeCallCount > 0)
    }

    #if DEBUG
    @Test
    func resetSeedFlag_removesUserDefaultsFlag() {
        let defaults = makeTestDefaults()
        defaults.set(true, forKey: SeedDataService.hasSeedDataLoadedKey)

        SeedDataService.resetSeedFlag(userDefaults: defaults)

        #expect(defaults.bool(forKey: SeedDataService.hasSeedDataLoadedKey) == false)
    }
    #endif
}
