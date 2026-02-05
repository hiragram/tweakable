import Testing
import Foundation
@testable import AppCore

@Suite
struct SeedDataServiceTests {
    /// テスト間の干渉を防ぐためのUserDefaultsキー
    private static let testKey = "hasSeedDataLoaded"

    private func cleanupUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Self.testKey)
    }

    @Test
    func seedIfNeeded_whenAlreadyLoaded_skipsSeeding() async {
        UserDefaults.standard.set(true, forKey: Self.testKey)
        let mockPersistence = MockRecipePersistenceService()
        let service = SeedDataService(persistenceService: mockPersistence)

        await service.seedIfNeeded()

        #expect(mockPersistence.saveRecipeCallCount == 0)
        #expect(mockPersistence.createCategoryCallCount == 0)

        cleanupUserDefaults()
    }

    @Test
    func seedIfNeeded_whenNotLoaded_createsCategoryAndSavesRecipes() async {
        cleanupUserDefaults()
        let mockPersistence = MockRecipePersistenceService()
        let service = SeedDataService(persistenceService: mockPersistence)

        await service.seedIfNeeded()

        #expect(mockPersistence.createCategoryCallCount == 1)
        #expect(mockPersistence.saveRecipeCallCount > 0)
        #expect(mockPersistence.addRecipeToCategoryCallCount > 0)

        cleanupUserDefaults()
    }

    @Test
    func seedIfNeeded_whenNotLoaded_setsFlagAfterCompletion() async {
        cleanupUserDefaults()
        let mockPersistence = MockRecipePersistenceService()
        let service = SeedDataService(persistenceService: mockPersistence)

        await service.seedIfNeeded()

        #expect(UserDefaults.standard.bool(forKey: Self.testKey) == true)

        cleanupUserDefaults()
    }

    @Test
    func seedIfNeeded_whenPersistenceFails_doesNotSetFlag() async {
        cleanupUserDefaults()
        let mockPersistence = MockRecipePersistenceService()
        mockPersistence.errorToThrow = NSError(domain: "test", code: 1)
        let service = SeedDataService(persistenceService: mockPersistence)

        await service.seedIfNeeded()

        #expect(UserDefaults.standard.bool(forKey: Self.testKey) == false)

        cleanupUserDefaults()
    }

    @Test
    func seedIfNeeded_whenCategoryExists_reusesExistingCategory() async {
        cleanupUserDefaults()
        let mockPersistence = MockRecipePersistenceService()
        // 既存カテゴリを追加
        let existingCategory = RecipeCategory(name: SeedData.categoryName)
        mockPersistence.categories[existingCategory.id] = existingCategory
        let service = SeedDataService(persistenceService: mockPersistence)

        await service.seedIfNeeded()

        // 新規カテゴリは作成されない（既存が再利用される）
        #expect(mockPersistence.createCategoryCallCount == 0)
        #expect(mockPersistence.saveRecipeCallCount > 0)

        cleanupUserDefaults()
    }

    #if DEBUG
    @Test
    func resetSeedFlag_removesUserDefaultsFlag() {
        UserDefaults.standard.set(true, forKey: Self.testKey)

        SeedDataService.resetSeedFlag()

        #expect(UserDefaults.standard.bool(forKey: Self.testKey) == false)
    }
    #endif
}
