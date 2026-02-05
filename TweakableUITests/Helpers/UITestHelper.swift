//
//  UITestHelper.swift
//  TweakableUITests
//

import XCTest

// MARK: - Paywall Accessibility IDs

enum PaywallAccessibilityIDs {
    static let dismissButton = "paywall_button_dismiss"
    static let restoreButton = "paywall_button_restore"
}

// MARK: - AddRecipe Accessibility IDs

enum AddRecipeAccessibilityIDs {
    static let urlTextField = "addRecipe_textField_url"
    static let extractButton = "addRecipe_button_extract"
    static let clearButton = "addRecipe_button_clear"
    static let closeButton = "addRecipe_button_close"
}

// MARK: - Recipe Accessibility IDs

enum RecipeAccessibilityIDs {
    // RecipeView
    static let loadingView = "recipe_view_loading"
    static let errorView = "recipe_view_error"
    static let errorRetryButton = "recipe_button_retry"
    static func ingredientItem(_ index: Int) -> String { "recipe_button_ingredient_\(index)" }
    static func stepItem(_ index: Int) -> String { "recipe_button_step_\(index)" }
    static let modifiedBadge = "recipe_badge_modified"

    // SubstitutionSheetView
    static let promptTextField = "substitutionSheet_textField_prompt"
    static let submitButton = "substitutionSheet_button_submit"
    static let upgradeButton = "substitutionSheet_button_upgrade"
    static let substitutionErrorText = "substitutionSheet_text_error"

    // SubstitutionSheetView - Preview Mode
    static let approveButton = "substitutionSheet_button_approve"
    static let rejectButton = "substitutionSheet_button_reject"
    static let requestMoreButton = "substitutionSheet_button_requestMore"
    static let additionalPromptTextField = "substitutionSheet_textField_additionalPrompt"
    static let sendMoreButton = "substitutionSheet_button_sendMore"
}

// MARK: - SavedRecipesList Accessibility IDs

enum SavedRecipesListAccessibilityID {
    static let list = "savedRecipesList_list"
    static let emptyView = "savedRecipesList_view_empty"
    static func recipeRow(_ id: String) -> String { "savedRecipesList_button_recipe_\(id)" }
}

// MARK: - RecipeHome Accessibility IDs

enum RecipeHomeAccessibilityIDs {
    static let emptyView = "recipeHome_view_empty"
    static let emptyAddButton = "recipeHome_button_emptyAdd"
    static let grid = "recipeHome_grid"
    static let addButton = "recipeHome_button_add"
    static let shoppingListsButton = "recipeHome_button_shoppingLists"
}

// MARK: - UITestHelper

enum UITestHelper {
    /// レシピホーム画面が表示されるまで待機
    /// - Note: 2列グリッドホーム画面に対応。ツールバーの追加ボタンまたはグリッドを確認
    /// - Returns: レシピホーム画面に到達できたかどうか
    static func waitForRecipeHomeScreen(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        // ツールバーの追加ボタンまたはグリッドが表示されることを確認
        let grid = app.otherElements[RecipeHomeAccessibilityIDs.grid]
        let addButton = app.buttons[RecipeHomeAccessibilityIDs.addButton]

        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if grid.exists || addButton.exists {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }

    /// レシピ詳細画面が表示されるまで待機
    /// - Returns: レシピ詳細画面に到達できたかどうか
    static func waitForRecipeView(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        // 最初の材料ボタンが表示されることでレシピ詳細画面への到達を確認
        let firstIngredient = app.buttons[RecipeAccessibilityIDs.ingredientItem(0)]
        return firstIngredient.waitForExistence(timeout: timeout)
    }

    /// ローディング画面が表示されるまで待機
    /// - Returns: ローディング画面が表示されているかどうか
    static func waitForRecipeLoading(app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let loadingView = app.otherElements[RecipeAccessibilityIDs.loadingView]
        return loadingView.waitForExistence(timeout: timeout)
    }

    /// エラー画面が表示されるまで待機
    /// - Returns: エラー画面が表示されているかどうか
    static func waitForRecipeError(app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let errorView = app.otherElements[RecipeAccessibilityIDs.errorView]
        return errorView.waitForExistence(timeout: timeout)
    }

    /// 置き換えシートが表示されるまで待機
    /// - Returns: 置き換えシートが表示されているかどうか
    static func waitForSubstitutionSheet(app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        // submitButtonまたはupgradeButtonが表示されることを確認
        let submitButton = app.buttons[RecipeAccessibilityIDs.submitButton]
        let upgradeButton = app.buttons[RecipeAccessibilityIDs.upgradeButton]

        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if submitButton.exists || upgradeButton.exists {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }

    /// AddRecipeシートを開く
    /// - Note: ホーム画面からAddRecipeシートを開く。ツールバーの追加ボタンを使用
    static func openAddRecipeSheet(app: XCUIApplication) {
        // ツールバーの追加ボタンを使う（空状態でも常に表示される）
        let addButton = app.buttons[RecipeHomeAccessibilityIDs.addButton]

        if addButton.exists {
            addButton.tap()
        }
    }

    /// AddRecipeシートが表示されるまで待機
    static func waitForAddRecipeSheet(app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let urlTextField = app.textFields[AddRecipeAccessibilityIDs.urlTextField]
        return urlTextField.waitForExistence(timeout: timeout)
    }

    /// URLを入力してレシピ抽出を開始
    /// - Note: AddRecipeシートが開いている状態で呼び出すこと
    /// - Parameters:
    ///   - app: XCUIApplication
    ///   - url: 入力するURL文字列
    /// - Note: RecipeHomeView（Empty State）からAddRecipeViewを開き、URLを入力して抽出を開始
    static func extractRecipe(app: XCUIApplication, url: String) {
        // 空状態の場合、まずシートを開く
        let urlTextField = app.textFields[AddRecipeAccessibilityIDs.urlTextField]
        if !urlTextField.exists {
            openAddRecipeSheet(app: app)
            _ = waitForAddRecipeSheet(app: app)
        }

        urlTextField.tap()
        urlTextField.typeText(url)

        let extractButton = app.buttons[AddRecipeAccessibilityIDs.extractButton]
        extractButton.tap()
    }

    /// 入力フィールドをクリア
    static func clearURLField(app: XCUIApplication) {
        let clearButton = app.buttons[AddRecipeAccessibilityIDs.clearButton]
        if clearButton.exists {
            clearButton.tap()
        }
    }

    /// 材料をタップして置き換えシートを開く
    /// - Parameters:
    ///   - app: XCUIApplication
    ///   - index: 材料のインデックス（0始まり）
    static func tapIngredient(app: XCUIApplication, at index: Int) {
        let ingredientButton = app.buttons[RecipeAccessibilityIDs.ingredientItem(index)]
        ingredientButton.tap()
    }

    /// 調理工程をタップして置き換えシートを開く
    /// - Parameters:
    ///   - app: XCUIApplication
    ///   - index: 工程のインデックス（0始まり）
    static func tapStep(app: XCUIApplication, at index: Int) {
        let stepButton = app.buttons[RecipeAccessibilityIDs.stepItem(index)]
        stepButton.tap()
    }

    /// 置き換えシートのプレビューモードが表示されるまで待機
    /// - Returns: プレビューモードが表示されているかどうか
    static func waitForSubstitutionPreview(app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        // approveButton（これでOK）が表示されることを確認
        let approveButton = app.buttons[RecipeAccessibilityIDs.approveButton]
        return approveButton.waitForExistence(timeout: timeout)
    }

    /// プレビューモードで「これでOK」をタップして置き換えを承認
    static func approveSubstitution(app: XCUIApplication) {
        let approveButton = app.buttons[RecipeAccessibilityIDs.approveButton]
        guard approveButton.waitForExistence(timeout: 5) else {
            XCTFail("approveSubstitution: 承認ボタンが見つかりません")
            return
        }
        approveButton.tap()
    }

    /// プレビューモードで「やっぱりやめる」をタップして置き換えを却下
    static func rejectSubstitution(app: XCUIApplication) {
        let rejectButton = app.buttons[RecipeAccessibilityIDs.rejectButton]
        guard rejectButton.waitForExistence(timeout: 5) else {
            XCTFail("rejectSubstitution: 却下ボタンが見つかりません")
            return
        }
        rejectButton.tap()
    }

    /// 置き換えプロンプトを入力して送信
    /// - Parameters:
    ///   - app: XCUIApplication
    ///   - prompt: 置き換え指示のテキスト
    static func submitSubstitution(app: XCUIApplication, prompt: String) {
        // まずシートが開いていることを確認（submitButtonの存在で判断）
        let submitButton = app.buttons[RecipeAccessibilityIDs.submitButton]
        guard submitButton.waitForExistence(timeout: 5) else {
            XCTFail("submitSubstitution: 送信ボタンが見つかりません")
            return
        }

        // TextEditorはtextViewsで見つかる
        let promptTextField = app.textViews[RecipeAccessibilityIDs.promptTextField]
        guard promptTextField.waitForExistence(timeout: 3) else {
            XCTFail("submitSubstitution: プロンプトフィールドが見つかりません")
            return
        }

        promptTextField.tap()
        promptTextField.typeText(prompt)

        // 送信ボタンをタップ
        submitButton.tap()
    }

    /// 要素が存在することを確認（タイムアウト付き）
    static func assertElementExists(
        _ element: XCUIElement,
        timeout: TimeInterval = 5,
        message: String? = nil
    ) {
        let defaultMessage = "要素が見つかりませんでした: \(element.identifier)"
        XCTAssertTrue(
            element.waitForExistence(timeout: timeout),
            message ?? defaultMessage
        )
    }

    // MARK: - Paywall Helpers

    /// ペイウォール画面が表示されるまで待機
    /// - Returns: ペイウォールが表示されているかどうか
    static func waitForPaywall(app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let dismissButton = app.buttons[PaywallAccessibilityIDs.dismissButton]
        return dismissButton.waitForExistence(timeout: timeout)
    }

    /// ペイウォール画面を閉じる
    static func dismissPaywall(app: XCUIApplication) {
        let dismissButton = app.buttons[PaywallAccessibilityIDs.dismissButton]
        if dismissButton.exists {
            dismissButton.tap()
        }
    }

    // MARK: - SavedRecipes Helpers

    /// 保存済みレシピボタンをタップ
    /// - Note: レガシー機能。現在のホーム画面は直接グリッド表示でこのボタンは存在しない可能性がある
    @available(*, deprecated, message: "SavedRecipes is now the home screen grid. This function may not work as expected.")
    static func tapSavedRecipesButton(app: XCUIApplication) {
        // この機能は現在使われていない（ホーム画面がグリッド表示になったため）
    }

    /// 保存済みレシピ一覧画面が表示されるまで待機
    /// - Returns: 保存済みレシピ一覧画面が表示されているかどうか
    static func waitForSavedRecipesList(app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        // リストまたは空ビューが表示されることを確認
        let list = app.otherElements[SavedRecipesListAccessibilityID.list]
        let emptyView = app.otherElements[SavedRecipesListAccessibilityID.emptyView]

        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if list.exists || emptyView.exists {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }
}
