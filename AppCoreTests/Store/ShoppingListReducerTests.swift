import Testing
import Foundation
@testable import AppCore

@Suite
struct ShoppingListReducerTests {

    // MARK: - Test Helpers

    private func makeSampleRecipe(id: UUID = UUID(), title: String = "テスト料理") -> Recipe {
        Recipe(
            id: id,
            title: title,
            ingredientsInfo: Ingredients(
                servings: "2人分",
                sections: [
                    IngredientSection(items: [
                        Ingredient(name: "鶏肉", amount: "200g"),
                        Ingredient(name: "塩", amount: "少々")
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "鶏肉を切る"),
                    CookingStep(stepNumber: 2, instruction: "塩をふる")
                ])
            ],
            sourceURL: URL(string: "https://example.com/recipe")
        )
    }

    private func makeSampleShoppingList(
        id: UUID = UUID(),
        name: String = "今週の買い物"
    ) -> ShoppingListDTO {
        ShoppingListDTO(
            id: id,
            name: name,
            createdAt: Date(),
            updatedAt: Date(),
            recipeIDs: [],
            items: []
        )
    }

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = ShoppingListState()

        #expect(state.shoppingLists == [])
        #expect(state.currentShoppingList == nil)
        #expect(state.isLoadingLists == false)
        #expect(state.isCreatingList == false)
        #expect(state.isDeletingList == false)
        #expect(state.errorMessage == nil)
    }

    // MARK: - Load Shopping Lists Tests

    @Test
    func reduce_loadShoppingLists_setsLoadingState() {
        var state = ShoppingListState()

        ShoppingListReducer.reduce(state: &state, action: .loadShoppingLists)

        #expect(state.isLoadingLists == true)
    }

    @Test
    func reduce_shoppingListsLoaded_setsListsAndClearsLoading() {
        var state = ShoppingListState()
        state.isLoadingLists = true
        let lists = [makeSampleShoppingList(), makeSampleShoppingList(name: "週末の買い物")]

        ShoppingListReducer.reduce(state: &state, action: .shoppingListsLoaded(lists))

        #expect(state.shoppingLists.count == 2)
        #expect(state.isLoadingLists == false)
    }

    @Test
    func reduce_shoppingListsLoadFailed_setsErrorAndClearsLoading() {
        var state = ShoppingListState()
        state.isLoadingLists = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListsLoadFailed("読み込みエラー"))

        #expect(state.errorMessage == "読み込みエラー")
        #expect(state.isLoadingLists == false)
    }

    // MARK: - Create Shopping List Tests

    @Test
    func reduce_createShoppingList_setsCreatingState() {
        var state = ShoppingListState()

        ShoppingListReducer.reduce(state: &state, action: .createShoppingList(name: "新しいリスト", recipeIDs: []))

        #expect(state.isCreatingList == true)
    }

    @Test
    func reduce_shoppingListCreated_addsToListsAndClearsCreating() {
        var state = ShoppingListState()
        state.isCreatingList = true
        let newList = makeSampleShoppingList()

        ShoppingListReducer.reduce(state: &state, action: .shoppingListCreated(newList))

        #expect(state.shoppingLists.contains { $0.id == newList.id })
        #expect(state.isCreatingList == false)
    }

    @Test
    func reduce_shoppingListCreateFailed_setsErrorAndClearsCreating() {
        var state = ShoppingListState()
        state.isCreatingList = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListCreateFailed("作成エラー"))

        #expect(state.errorMessage == "作成エラー")
        #expect(state.isCreatingList == false)
    }

    // MARK: - Delete Shopping List Tests

    @Test
    func reduce_deleteShoppingList_setsDeletingState() {
        var state = ShoppingListState()
        let list = makeSampleShoppingList()
        state.shoppingLists = [list]

        ShoppingListReducer.reduce(state: &state, action: .deleteShoppingList(id: list.id))

        #expect(state.isDeletingList == true)
    }

    @Test
    func reduce_shoppingListDeleted_removesFromLists() {
        var state = ShoppingListState()
        let list = makeSampleShoppingList()
        state.shoppingLists = [list]
        state.isDeletingList = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListDeleted(id: list.id))

        #expect(!state.shoppingLists.contains { $0.id == list.id })
        #expect(state.isDeletingList == false)
    }

    @Test
    func reduce_shoppingListDeleted_clearsCurrentShoppingListIfDeleted() {
        var state = ShoppingListState()
        let list = makeSampleShoppingList()
        state.shoppingLists = [list]
        state.currentShoppingList = list
        state.isDeletingList = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListDeleted(id: list.id))

        #expect(state.currentShoppingList == nil)
        #expect(!state.shoppingLists.contains { $0.id == list.id })
        #expect(state.isDeletingList == false)
    }

    @Test
    func reduce_shoppingListDeleted_keepsCurrentShoppingListIfDifferent() {
        var state = ShoppingListState()
        let listToDelete = makeSampleShoppingList(id: UUID(), name: "削除するリスト")
        let currentList = makeSampleShoppingList(id: UUID(), name: "現在のリスト")
        state.shoppingLists = [listToDelete, currentList]
        state.currentShoppingList = currentList
        state.isDeletingList = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListDeleted(id: listToDelete.id))

        #expect(state.currentShoppingList == currentList)
        #expect(state.shoppingLists.count == 1)
    }

    @Test
    func reduce_shoppingListDeleteFailed_setsError() {
        var state = ShoppingListState()
        state.isDeletingList = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListDeleteFailed("削除エラー"))

        #expect(state.errorMessage == "削除エラー")
        #expect(state.isDeletingList == false)
    }

    // MARK: - Select Shopping List Tests

    @Test
    func reduce_selectShoppingList_setsCurrent() {
        var state = ShoppingListState()
        let list = makeSampleShoppingList()
        state.shoppingLists = [list]

        ShoppingListReducer.reduce(state: &state, action: .selectShoppingList(list))

        #expect(state.currentShoppingList == list)
    }

    @Test
    func reduce_clearCurrentShoppingList_clearsSelection() {
        var state = ShoppingListState()
        state.currentShoppingList = makeSampleShoppingList()

        ShoppingListReducer.reduce(state: &state, action: .clearCurrentShoppingList)

        #expect(state.currentShoppingList == nil)
    }

    // MARK: - Update Item Check Tests

    @Test
    func reduce_updateItemChecked_setsUpdatingState() {
        var state = ShoppingListState()

        ShoppingListReducer.reduce(state: &state, action: .updateItemChecked(itemID: UUID(), isChecked: true))

        #expect(state.isUpdatingItem == true)
    }

    @Test
    func reduce_itemCheckedUpdated_updatesItemInCurrentList() {
        var state = ShoppingListState()
        let itemID = UUID()
        let item = ShoppingListItemDTO(
            id: itemID,
            name: "鶏肉",
            totalAmount: "200g",
            category: nil,
            isChecked: false,
            breakdowns: []
        )
        let list = ShoppingListDTO(
            id: UUID(),
            name: "テスト",
            createdAt: Date(),
            updatedAt: Date(),
            recipeIDs: [],
            items: [item]
        )
        state.currentShoppingList = list
        state.isUpdatingItem = true

        ShoppingListReducer.reduce(state: &state, action: .itemCheckedUpdated(itemID: itemID, isChecked: true))

        #expect(state.currentShoppingList?.items.first { $0.id == itemID }?.isChecked == true)
        #expect(state.isUpdatingItem == false)
    }

    @Test
    func reduce_itemCheckedUpdated_handlesNilCurrentShoppingList() {
        var state = ShoppingListState()
        state.currentShoppingList = nil
        state.isUpdatingItem = true
        let itemID = UUID()

        ShoppingListReducer.reduce(state: &state, action: .itemCheckedUpdated(itemID: itemID, isChecked: true))

        #expect(state.currentShoppingList == nil)
        #expect(state.isUpdatingItem == false)
    }

    @Test
    func reduce_itemCheckedUpdated_handlesNonExistentItemID() {
        var state = ShoppingListState()
        let existingItemID = UUID()
        let nonExistentItemID = UUID()
        let item = ShoppingListItemDTO(
            id: existingItemID,
            name: "鶏肉",
            totalAmount: "200g",
            category: nil,
            isChecked: false,
            breakdowns: []
        )
        let list = ShoppingListDTO(
            id: UUID(),
            name: "テスト",
            createdAt: Date(),
            updatedAt: Date(),
            recipeIDs: [],
            items: [item]
        )
        state.currentShoppingList = list
        state.isUpdatingItem = true

        ShoppingListReducer.reduce(state: &state, action: .itemCheckedUpdated(itemID: nonExistentItemID, isChecked: true))

        // 既存アイテムのisCheckedは変更されない
        #expect(state.currentShoppingList?.items.first { $0.id == existingItemID }?.isChecked == false)
        #expect(state.isUpdatingItem == false)
    }

    @Test
    func reduce_itemCheckUpdateFailed_setsError() {
        var state = ShoppingListState()
        state.isUpdatingItem = true

        ShoppingListReducer.reduce(state: &state, action: .itemCheckUpdateFailed("更新エラー"))

        #expect(state.errorMessage == "更新エラー")
        #expect(state.isUpdatingItem == false)
    }

    // MARK: - Clear Error Tests

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = ShoppingListState()
        state.errorMessage = "エラー"

        ShoppingListReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }

    // MARK: - Additional Edge Case Tests

    @Test
    func reduce_shoppingListCreated_appendsToExistingLists() {
        var state = ShoppingListState()
        let existingList = makeSampleShoppingList(name: "既存リスト")
        state.shoppingLists = [existingList]
        state.isCreatingList = true
        let newList = makeSampleShoppingList(name: "新しいリスト")

        ShoppingListReducer.reduce(state: &state, action: .shoppingListCreated(newList))

        #expect(state.shoppingLists.count == 2)
        #expect(state.shoppingLists.contains { $0.id == existingList.id })
        #expect(state.shoppingLists.contains { $0.id == newList.id })
    }

    @Test
    func reduce_itemCheckedUpdated_uncheckPreviouslyCheckedItem() {
        var state = ShoppingListState()
        let itemID = UUID()
        let item = ShoppingListItemDTO(
            id: itemID,
            name: "鶏肉",
            totalAmount: "200g",
            category: nil,
            isChecked: true, // 既にチェック済み
            breakdowns: []
        )
        let list = ShoppingListDTO(
            id: UUID(),
            name: "テスト",
            createdAt: Date(),
            updatedAt: Date(),
            recipeIDs: [],
            items: [item]
        )
        state.currentShoppingList = list
        state.isUpdatingItem = true

        ShoppingListReducer.reduce(state: &state, action: .itemCheckedUpdated(itemID: itemID, isChecked: false))

        #expect(state.currentShoppingList?.items.first { $0.id == itemID }?.isChecked == false)
    }

    @Test
    func reduce_shoppingListDeleted_fromMultipleLists_onlyRemovesTarget() {
        var state = ShoppingListState()
        let list1 = makeSampleShoppingList(id: UUID(), name: "リスト1")
        let list2 = makeSampleShoppingList(id: UUID(), name: "リスト2")
        let list3 = makeSampleShoppingList(id: UUID(), name: "リスト3")
        state.shoppingLists = [list1, list2, list3]
        state.isDeletingList = true

        ShoppingListReducer.reduce(state: &state, action: .shoppingListDeleted(id: list2.id))

        #expect(state.shoppingLists.count == 2)
        #expect(state.shoppingLists.contains { $0.id == list1.id })
        #expect(!state.shoppingLists.contains { $0.id == list2.id })
        #expect(state.shoppingLists.contains { $0.id == list3.id })
    }
}
