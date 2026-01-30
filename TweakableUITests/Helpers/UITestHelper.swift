//
//  UITestHelper.swift
//  TweakableUITests
//

import XCTest

// MARK: - Recipe Accessibility IDs

enum RecipeAccessibilityIDs {
    // RecipeHomeView
    static let urlTextField = "recipeHome_textField_url"
    static let extractButton = "recipeHome_button_extract"
    static let clearButton = "recipeHome_button_clear"

    // RecipeView
    static let loadingView = "recipe_view_loading"
    static let errorView = "recipe_view_error"
    static let errorRetryButton = "recipe_button_retry"
    static func ingredientItem(_ index: Int) -> String { "recipe_button_ingredient_\(index)" }
    static func stepItem(_ index: Int) -> String { "recipe_button_step_\(index)" }
    static let shoppingListButton = "recipe_button_shoppingList"
    static let modifiedBadge = "recipe_badge_modified"

    // SubstitutionSheetView
    static let promptTextField = "substitutionSheet_textField_prompt"
    static let submitButton = "substitutionSheet_button_submit"
    static let upgradeButton = "substitutionSheet_button_upgrade"
    static let substitutionErrorText = "substitutionSheet_text_error"
}

// MARK: - UITestHelper

enum UITestHelper {
    /// レシピホーム画面（URL入力画面）が表示されるまで待機
    /// - Returns: レシピホーム画面に到達できたかどうか
    static func waitForRecipeHomeScreen(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        return urlTextField.waitForExistence(timeout: timeout)
    }

    /// レシピ詳細画面が表示されるまで待機
    /// - Returns: レシピ詳細画面に到達できたかどうか
    static func waitForRecipeView(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        // ツールバーのショッピングリストボタンが表示されることを確認
        let shoppingListButton = app.buttons[RecipeAccessibilityIDs.shoppingListButton]
        return shoppingListButton.waitForExistence(timeout: timeout)
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

    /// URLを入力してレシピ抽出を開始
    /// - Parameters:
    ///   - app: XCUIApplication
    ///   - url: 入力するURL文字列
    static func extractRecipe(app: XCUIApplication, url: String) {
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        urlTextField.tap()
        urlTextField.typeText(url)

        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        extractButton.tap()
    }

    /// 入力フィールドをクリア
    static func clearURLField(app: XCUIApplication) {
        let clearButton = app.buttons[RecipeAccessibilityIDs.clearButton]
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
}
