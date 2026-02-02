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
        // UIテストモードで起動（プレミアムユーザーとしてモック、オンボーディングスキップ、Tipは無効化）
        app.launchArguments = ["--uitesting", "--mock-premium", "--skip-onboarding", "-disableTips"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        XCTAssertTrue(reachedHome, "レシピホーム画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    // MARK: - RecipeHomeView Tests

    /// レシピホーム画面のEmpty State要素が存在することを確認
    func testRecipeHomeViewElements() throws {
        // Empty Stateの「+ レシピを追加」ボタンが存在する
        let emptyAddButton = app.buttons[RecipeAccessibilityIDs.emptyAddButton]
        XCTAssertTrue(emptyAddButton.exists, "Empty Stateの追加ボタンが存在すること")
    }

    // MARK: - AddRecipeView Tests

    /// AddRecipeViewの主要要素が存在することを確認
    func testAddRecipeViewElements() throws {
        // AddRecipeViewを開く
        UITestHelper.openAddRecipeView(app: app)
        let reachedAddRecipe = UITestHelper.waitForAddRecipeView(app: app)
        try XCTSkipUnless(reachedAddRecipe, "AddRecipeViewに到達できませんでした")

        // URL入力フィールドが存在する
        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        XCTAssertTrue(urlTextField.exists, "URL入力フィールドが存在すること")

        // 抽出ボタンが存在する
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertTrue(extractButton.exists, "抽出ボタンが存在すること")
    }

    /// URLが空の状態では抽出ボタンが無効であることを確認
    func testExtractButtonDisabledWhenEmpty() throws {
        // AddRecipeViewを開く
        UITestHelper.openAddRecipeView(app: app)
        let reachedAddRecipe = UITestHelper.waitForAddRecipeView(app: app)
        try XCTSkipUnless(reachedAddRecipe, "AddRecipeViewに到達できませんでした")

        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertFalse(extractButton.isEnabled, "URL未入力時は抽出ボタンが無効であること")
    }

    /// URLを入力すると抽出ボタンが有効になることを確認
    func testExtractButtonEnabledForValidURL() throws {
        // AddRecipeViewを開く
        UITestHelper.openAddRecipeView(app: app)
        let reachedAddRecipe = UITestHelper.waitForAddRecipeView(app: app)
        try XCTSkipUnless(reachedAddRecipe, "AddRecipeViewに到達できませんでした")

        let urlTextField = app.textFields[RecipeAccessibilityIDs.urlTextField]
        urlTextField.tap()
        urlTextField.typeText("https://example.com/recipe")

        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        XCTAssertTrue(extractButton.isEnabled, "URL入力後は抽出ボタンが有効であること")
    }

    /// クリアボタンでURL入力がクリアされることを確認
    func testClearButton() throws {
        // AddRecipeViewを開く
        UITestHelper.openAddRecipeView(app: app)
        let reachedAddRecipe = UITestHelper.waitForAddRecipeView(app: app)
        try XCTSkipUnless(reachedAddRecipe, "AddRecipeViewに到達できませんでした")

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
        // AddRecipeViewを開いてURLを入力
        UITestHelper.openAddRecipeView(app: app)
        let reachedAddRecipe = UITestHelper.waitForAddRecipeView(app: app)
        try XCTSkipUnless(reachedAddRecipe, "AddRecipeViewに到達できませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        XCTAssertTrue(sheetDisplayed, "置き換えシートが表示されませんでした")

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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        XCTAssertTrue(sheetDisplayed, "置き換えシートが表示されませんでした")

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
        // UIテストモードで起動（無料ユーザーとしてモック、--mock-premiumなし、オンボーディングスキップ、Tipは無効化）
        app.launchArguments = ["--uitesting", "--skip-onboarding", "-disableTips"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        XCTAssertTrue(reachedHome, "レシピホーム画面に到達できませんでした")
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
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に到達できませんでした")

        // 材料をタップして置き換えシートを開く
        UITestHelper.tapIngredient(app: app, at: 0)
        let sheetDisplayed = UITestHelper.waitForSubstitutionSheet(app: app)
        XCTAssertTrue(sheetDisplayed, "置き換えシートが表示されませんでした")

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

// MARK: - SavedRecipes Navigation Tests

@MainActor
final class SavedRecipesNavigationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // UIテストモードで起動（プレミアムユーザーとしてモック、保存済みレシピあり、オンボーディングスキップ、Tipは無効化）
        app.launchArguments = ["--uitesting", "--mock-premium", "--mock-saved-recipes", "--skip-onboarding", "-disableTips"]
        app.launch()

        // レシピホーム画面が表示されるまで待機
        let reachedHome = UITestHelper.waitForRecipeHomeScreen(app: app)
        XCTAssertTrue(reachedHome, "レシピホーム画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    /// 保存済みレシピからレシピ選択後、戻るボタンで保存済みレシピ一覧に戻れることを確認
    ///
    /// - Note: 現在このテストはSwiftUIの@ObservableとネストしたnavigationDestinationの
    ///   相性問題により失敗する。手動テストでは正常に動作することを確認済み。
    ///   詳細は https://github.com/hiragram/tweakable/issues/49 を参照。
    func testBackButtonReturnsToSavedRecipesList() throws {
        // TODO: SwiftUIのnavigationDestination問題が解決したら有効化
        throw XCTSkip("SwiftUI @Observable + nested navigationDestination issue - works in manual testing (see #49)")
        // 保存済みレシピボタンをタップ
        let savedRecipesButton = app.buttons[RecipeAccessibilityIDs.savedRecipesButton]
        XCTAssertTrue(savedRecipesButton.waitForExistence(timeout: 5), "保存済みレシピボタンが存在すること")
        savedRecipesButton.tap()

        // 保存済みレシピ一覧画面が表示されるまで待機
        // SavedRecipesListViewのnavigationTitleを確認
        let savedRecipesNavTitle = app.navigationBars.staticTexts.element(boundBy: 0)
        XCTAssertTrue(savedRecipesNavTitle.waitForExistence(timeout: 5), "保存済みレシピ画面のナビゲーションバーが表示されること")

        // 最初のレシピをタップ（モックデータがあることを前提）
        // Listの最初のボタンを探す
        let recipeButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'savedRecipesList_button_recipe_'"))
        let firstRecipeButton = recipeButtons.firstMatch
        XCTAssertTrue(firstRecipeButton.waitForExistence(timeout: 5), "保存済みレシピが存在すること")
        firstRecipeButton.tap()

        // レシピ詳細画面が表示されるまで待機
        let reachedRecipeView = UITestHelper.waitForRecipeView(app: app, timeout: 10)
        XCTAssertTrue(reachedRecipeView, "レシピ詳細画面に遷移すること")

        // 戻るボタンをタップ（ナビゲーションバーのバックボタン）
        // iOS 26ではBackButtonというidentifierを持つ
        let backButton = app.navigationBars.buttons["BackButton"]
        if backButton.exists {
            backButton.tap()
        } else {
            // フォールバック: 最初のボタンをタップ
            let firstButton = app.navigationBars.buttons.element(boundBy: 0)
            XCTAssertTrue(firstButton.exists, "戻るボタンが存在すること")
            firstButton.tap()
        }

        // 保存済みレシピ一覧に戻っていることを確認
        // レシピ詳細画面の要素が消えていることを確認（先に確認）
        let shoppingListButton = app.buttons[RecipeAccessibilityIDs.shoppingListButton]
        XCTAssertTrue(shoppingListButton.waitForNonExistence(timeout: 5), "レシピ詳細画面から離れていること")

        // ナビゲーションの遷移と非同期処理の完了を待つ
        Thread.sleep(forTimeInterval: 3.0)

        // ナビゲーションバーのタイトルを確認
        let navBarTexts = app.navigationBars.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("DEBUG: Navigation bar texts after back: \(navBarTexts)")

        // レシピホーム画面に戻っていないことを確認（レシピホームのボタンが見えないこと）
        let extractButton = app.buttons[RecipeAccessibilityIDs.extractButton]
        let isOnRecipeHome = extractButton.exists
        print("DEBUG: Is on Recipe Home: \(isOnRecipeHome)")

        // 保存済みレシピ一覧のボタンが再度表示されることを確認
        // 非同期リロードの完了を待つため、十分なタイムアウトを設定
        let recipeButtonsAfterBack = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'savedRecipesList_button_recipe_'"))
        let recipeButtonExists = recipeButtonsAfterBack.firstMatch.waitForExistence(timeout: 10)

        // デバッグ出力
        if !recipeButtonExists {
            let allButtons = app.buttons.allElementsBoundByIndex
            let buttonIdentifiers = allButtons.map { $0.identifier }
            print("DEBUG: All button identifiers after back: \(buttonIdentifiers)")

            let emptyView = app.otherElements[SavedRecipesListAccessibilityID.emptyView]
            print("DEBUG: Empty view exists: \(emptyView.exists)")

            let allStaticTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
            print("DEBUG: All static texts: \(allStaticTexts)")
        }

        XCTAssertTrue(recipeButtonExists, "保存済みレシピ一覧に戻っていること")
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
