//
//  RecipeErrorUITests.swift
//  TweakableUITests
//
//  レシピ機能のエラーケースUIテスト
//

import XCTest

// MARK: - Extraction Error Tests

@MainActor
final class RecipeExtractionErrorUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // UIテストモードで起動（抽出エラーモード、オンボーディングスキップ、Tipは無効化）
        app.launchArguments = ["--uitesting", "--mock-extraction-error", "--skip-onboarding", "-disableTips"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        try XCTSkipUnless(reachedHome, "レシピホーム画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    /// レシピ抽出失敗時にエラーアラートが表示されることを確認
    func testExtractRecipeError() throws {
        // URLを入力して抽出
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")

        // エラーアラートが表示される（RecipeHomeContainerViewでアラート表示）
        let alertExists = app.alerts.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(alertExists, "抽出エラー時にエラーアラートが表示されること")

        // OKボタンが存在する
        let okButton = app.alerts.buttons.firstMatch
        XCTAssertTrue(okButton.exists, "アラートにOKボタンが存在すること")
    }

    /// アラートを閉じて再度抽出を実行できることを確認
    func testExtractRecipeRetry() throws {
        // URLを入力して抽出
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")

        // エラーアラートが表示される
        let alertExists = app.alerts.firstMatch.waitForExistence(timeout: 10)
        try XCTSkipUnless(alertExists, "エラーアラートが表示されませんでした")

        // OKボタンをタップしてアラートを閉じる
        app.alerts.buttons.firstMatch.tap()

        // アラートが閉じる
        let alertDismissed = app.alerts.firstMatch.waitForNonExistence(timeout: 3)
        XCTAssertTrue(alertDismissed, "アラートが閉じること")

        // アラートを閉じた後、AddRecipeViewはまだ開いているはず
        // 抽出ボタンをタップして再度抽出を実行
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertTrue(extractButton.waitForExistence(timeout: 3), "AddRecipeViewがまだ開いていて抽出ボタンが存在すること")
        extractButton.tap()

        // 再度エラーアラートが表示される（モックはエラーを返し続ける）
        let alertExistsAgain = app.alerts.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(alertExistsAgain, "リトライ後に再度エラーアラートが表示されること")
    }
}

// MARK: - Substitution Error Tests

@MainActor
final class RecipeSubstitutionErrorUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // UIテストモードで起動（置き換えエラーモード + プレミアムユーザー、オンボーディングスキップ、Tipは無効化）
        app.launchArguments = ["--uitesting", "--mock-substitution-error", "--mock-premium", "--skip-onboarding", "-disableTips"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        try XCTSkipUnless(reachedHome, "レシピホーム画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    /// 置き換え失敗時にエラーメッセージが表示されることを確認
    func testSubstitutionError() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // 材料をタップしてシートを開く
        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        try XCTSkipUnless(sheetDisplayed, "置き換えシートが表示されませんでした")

        // 置き換えを実行
        UITestHelper.submitSubstitution(app: app, prompt: "豚肉に変えて")

        // エラーメッセージが表示される（SubstitutionSheetViewはエラーをインラインTextで表示）
        let errorText = app.staticTexts[RecipeAccessibilityIDs.substitutionErrorText]
        let errorExists = errorText.waitForExistence(timeout: 5)
        XCTAssertTrue(errorExists, "置き換えエラー時にエラーメッセージが表示されること")

        // シートがまだ開いている（リトライ可能）
        let submitButton = app.buttons[RecipeAccessibilityIDs.submitButton]
        XCTAssertTrue(submitButton.exists, "エラー後もシートが開いたままであること")
    }
}
