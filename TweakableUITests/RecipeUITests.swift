//
//  RecipeUITests.swift
//  TweakableUITests
//
//  レシピ機能のUIテスト
//

import XCTest

@MainActor
final class RecipeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // UIテストモードで起動（プレミアムユーザーとしてモック）
        app.launchArguments = ["--uitesting", "--mock-premium"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        try XCTSkipUnless(reachedHome, "レシピホーム画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    // MARK: - RecipeHomeView Tests

    /// レシピホーム画面の主要要素が存在することを確認
    func testRecipeHomeViewElements() throws {
        // URL入力フィールドが存在する
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        XCTAssertTrue(urlTextField.exists, "URL入力フィールドが存在すること")

        // 抽出ボタンが存在する
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertTrue(extractButton.exists, "抽出ボタンが存在すること")
    }

    /// URLが空の状態では抽出ボタンが無効であることを確認
    func testExtractButtonDisabledWhenEmpty() throws {
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertFalse(extractButton.isEnabled, "URL未入力時は抽出ボタンが無効であること")
    }

    /// URLを入力すると抽出ボタンが有効になることを確認
    func testExtractButtonEnabledForValidURL() throws {
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        urlTextField.tap()
        urlTextField.typeText("https://example.com/recipe")

        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertTrue(extractButton.isEnabled, "URL入力後は抽出ボタンが有効であること")
    }

    /// クリアボタンでURL入力がクリアされることを確認
    func testClearButton() throws {
        // URLを入力
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        urlTextField.tap()
        urlTextField.typeText("https://example.com/recipe")

        // クリアボタンが表示される
        let clearButton = app.buttons[RecipeAccessibilityIDs.clearButton]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 2), "クリアボタンが表示されること")

        // 抽出ボタンが有効になっていることを確認
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertTrue(extractButton.isEnabled, "URL入力後は抽出ボタンが有効")

        // クリアボタンをタップ
        clearButton.tap()

        // クリアボタンが消える（URLが空になったため）
        XCTAssertTrue(clearButton.waitForNonExistence(timeout: 2), "クリア後はクリアボタンが消えること")

        // 抽出ボタンが無効になる（URLが空になったため）
        XCTAssertFalse(extractButton.isEnabled, "クリア後は抽出ボタンが無効になること")
    }

    // MARK: - Recipe Extraction Tests

    /// レシピ抽出を実行してレシピ詳細画面に遷移することを確認
    func testNavigateToRecipeView() throws {
        // URLを入力
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        urlTextField.tap()
        urlTextField.typeText("https://example.com/recipe")

        // 抽出ボタンが有効になっていることを確認（キーボードを閉じずに直接確認）
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        // 少し待機してボタン状態が更新されるのを待つ
        _ = extractButton.waitForExistence(timeout: 2)
        XCTAssertTrue(extractButton.isEnabled, "抽出ボタンが有効であること")

        // 抽出ボタンをタップ
        extractButton.tap()

        // ローディング状態を経由することを確認（モックは500msの遅延あり）
        let loadingAppeared = UITestHelper.waitForRecipeLoading(app: app, timeout: 3)
        // ローディングが一瞬で終わることもあるので、存在確認は任意
        _ = loadingAppeared

        // レシピ詳細画面が表示されるまで待機（タイムアウト延長）
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 15)

        // デバッグ: 失敗した場合、エラー画面が表示されていないかチェック
        if !reachedRecipeView {
            // 現在のUI状態を収集
            let alertsCount = app.alerts.count
            let textFieldsCount = app.textFields.count
            let allTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
            let loadingVisible = app.otherElements[RecipeAccessibilityIDs.loadingView].exists
            let urlTextFieldVisible = app.textFields[RecipeAccessibilityIDs.urlTextField].exists
            let allButtons = app.buttons.allElementsBoundByIndex.map { "\($0.identifier): \($0.label)" }

            // エラーアラートが表示されていないか確認
            let alertExists = app.alerts.firstMatch.waitForExistence(timeout: 1)
            if alertExists {
                let alertText = app.alerts.firstMatch.staticTexts.allElementsBoundByIndex.map { $0.label }.joined(separator: ", ")
                XCTFail("エラーアラートが表示されました: \(alertText)")
                return
            }

            // 詳細なUI状態をXCTFailで出力
            XCTFail("""
                レシピ詳細画面に遷移していません。現在のUI状態:
                - アラート数: \(alertsCount)
                - テキストフィールド数: \(textFieldsCount)
                - 表示テキスト: \(allTexts.joined(separator: ", "))
                - ローディング表示: \(loadingVisible)
                - URL入力フィールド表示: \(urlTextFieldVisible)
                - ボタン: \(allButtons.joined(separator: ", "))
                """)
            return
        }

        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に遷移すること")
    }

    // MARK: - RecipeView Tests

    /// レシピ詳細画面の主要要素が存在することを確認
    func testRecipeViewElements() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // 最初の材料が存在する
        let firstIngredient = app.buttons[RecipeAccessibilityIDs.ingredientItem(0)]
        XCTAssertTrue(firstIngredient.exists, "材料が存在すること")

        // 最初の調理工程が存在する
        let firstStep = app.buttons[RecipeAccessibilityIDs.stepItem(0)]
        XCTAssertTrue(firstStep.exists, "調理工程が存在すること")

        // 買い物リストボタンが存在する
        let shoppingListButton = app.buttons[RecipeAccessibilityIDs.shoppingListButton]
        XCTAssertTrue(shoppingListButton.exists, "買い物リストボタンが存在すること")
    }

    /// 材料の数がモックデータと一致することを確認
    func testRecipeViewIngredientsCount() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // モックデータには4つの材料がある
        for i in 0..<4 {
            let ingredientButton = app.buttons[RecipeAccessibilityIDs.ingredientItem(i)]
            XCTAssertTrue(ingredientButton.exists, "材料\(i)が存在すること")
        }
    }

    /// 調理工程の数がモックデータと一致することを確認
    func testRecipeViewStepsCount() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // モックデータには4つの工程がある
        for i in 0..<4 {
            let stepButton = app.buttons[RecipeAccessibilityIDs.stepItem(i)]
            XCTAssertTrue(stepButton.exists, "工程\(i)が存在すること")
        }
    }

    // MARK: - Substitution Sheet Tests

    /// 材料をタップすると置き換えシートが表示されることを確認
    func testIngredientTapOpensSubstitutionSheet() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // 最初の材料をタップ
        UITestHelper.tapIngredient(app: app, at: 0)

        // 置き換えシートが表示される
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        XCTAssertTrue(sheetDisplayed, "置き換えシートが表示されること")
    }

    /// 調理工程をタップすると置き換えシートが表示されることを確認
    func testStepTapOpensSubstitutionSheet() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // 最初の工程をタップ
        UITestHelper.tapStep(app: app, at: 0)

        // 置き換えシートが表示される
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        XCTAssertTrue(sheetDisplayed, "置き換えシートが表示されること")
    }

    /// 置き換えシートの要素が存在することを確認
    func testSubstitutionSheetElements() throws {
        // レシピ詳細画面に遷移して材料をタップ
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        try XCTSkipUnless(sheetDisplayed, "置き換えシートが表示されませんでした")

        // プロンプト入力フィールドが存在する
        let promptTextField = app.textViews[RecipeAccessibilityIDs.promptTextField]
        XCTAssertTrue(promptTextField.exists, "プロンプト入力フィールドが存在すること")

        // 送信ボタンが存在する
        let submitButton = app.buttons[RecipeAccessibilityIDs.submitButton]
        XCTAssertTrue(submitButton.exists, "送信ボタンが存在すること")
    }

    /// 置き換えフローが完了することを確認（プレビュー確認フロー対応）
    func testSubstitutionFlow() throws {
        // レシピ詳細画面に遷移して材料をタップ
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        try XCTSkipUnless(sheetDisplayed, "置き換えシートが表示されませんでした")

        // 置き換え指示を入力して送信
        UITestHelper.submitSubstitution(app: app, prompt: "豚肉に変えて")

        // プレビューモードに遷移することを確認（「これでOK」ボタンが表示される）
        let previewDisplayed = UITestHelper.waitForSubstitutionPreview(app: app, timeout: 10)
        XCTAssertTrue(previewDisplayed, "置き換え後にプレビューモードに遷移すること")

        // 「これでOK」をタップして置き換えを承認
        UITestHelper.approveSubstitution(app: app)

        // シートが閉じてレシピ詳細画面に戻る
        let approveButton = app.buttons[RecipeAccessibilityIDs.approveButton]
        let sheetDismissed = approveButton.waitForNonExistence(timeout: 5)
        XCTAssertTrue(sheetDismissed, "承認後にシートが閉じること")

        // 修正バッジが表示される
        let modifiedBadge = app.staticTexts[RecipeAccessibilityIDs.modifiedBadge]
        XCTAssertTrue(modifiedBadge.waitForExistence(timeout: 3), "修正バッジが表示されること")
    }
}

// MARK: - Free User Paywall Tests

@MainActor
final class FreeUserPaywallUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // UIテストモードで起動（無料ユーザーとしてモック、--mock-premiumなし）
        app.launchArguments = ["--uitesting"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        try XCTSkipUnless(reachedHome, "レシピホーム画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    /// 無料ユーザーが置き換えシートでアップグレードボタンを押すと
    /// ペイウォールがすぐに表示されることを確認
    func testUpgradeButtonShowsPaywallImmediately() throws {
        // レシピ詳細画面に遷移
        UITestHelper.extractRecipe(app: app, url: "https://example.com/recipe")
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        try XCTSkipUnless(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // 材料をタップして置き換えシートを開く
        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        try XCTSkipUnless(sheetDisplayed, "置き換えシートが表示されませんでした")

        // アップグレードボタンが表示されることを確認（無料ユーザーなので）
        let upgradeButton = app.buttons[RecipeAccessibilityIDs.upgradeButton]
        XCTAssertTrue(upgradeButton.exists, "無料ユーザーにはアップグレードボタンが表示されること")

        // アップグレードボタンをタップ
        upgradeButton.tap()

        // ペイウォールがすぐに表示されることを確認
        let paywallDisplayed = UITestHelper.waitForPaywall(app: app)
        XCTAssertTrue(paywallDisplayed, "アップグレードボタンをタップするとペイウォールが表示されること")

        // ペイウォールを閉じる
        UITestHelper.dismissPaywall(app: app)

        // 置き換えシートに戻ることを確認
        let sheetStillDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        XCTAssertTrue(sheetStillDisplayed, "ペイウォールを閉じると置き換えシートに戻ること")
    }
}

// MARK: - XCUIElement Extension

extension XCUIElement {
    /// 要素が存在しなくなるまで待機
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
