//
//  HomeUITests.swift
//  OkumukaUITests
//

import XCTest

final class HomeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // ホーム画面に到達できない場合はスキップ
        let isHomeVisible = UITestHelper.waitForHomeScreen(app: app, timeout: 15)
        try XCTSkipUnless(isHomeVisible, "ホーム画面に到達できませんでした（iCloud未サインインまたはグループ未参加）")
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Home View Elements Tests

    @MainActor
    func testHomeViewElements() throws {
        // ホーム画面の主要要素の存在確認
        let enterScheduleButton = app.buttons[CommonAccessibilityIDs.homeEnterScheduleButton]
        UITestHelper.assertElementExists(enterScheduleButton, message: "予定入力ボタンが見つかりません")

        let settingsButton = app.buttons[CommonAccessibilityIDs.homeSettingsButton]
        UITestHelper.assertElementExists(settingsButton, message: "設定ボタンが見つかりません")

        let groupSelector = app.descendants(matching: .any)[CommonAccessibilityIDs.homeGroupSelector]
        UITestHelper.assertElementExists(groupSelector, message: "グループセレクタが見つかりません")
    }

    // MARK: - Navigation Tests

    @MainActor
    func testNavigateToScheduleInput() throws {
        // スケジュール入力画面を開く
        UITestHelper.openScheduleInput(app: app)

        // スケジュール画面の要素が表示されることを確認
        let submitButton = app.buttons[CommonAccessibilityIDs.weeklyScheduleSubmitButton]
        UITestHelper.assertElementExists(submitButton, message: "スケジュール画面への遷移に失敗しました")
    }

    @MainActor
    func testNavigateToSettings() throws {
        // 設定画面を開く
        UITestHelper.openSettings(app: app)

        // 設定画面の要素が表示されることを確認
        let doneButton = app.buttons[CommonAccessibilityIDs.settingsDoneButton]
        UITestHelper.assertElementExists(doneButton, message: "設定画面への遷移に失敗しました")

        // 閉じる
        doneButton.tap()
    }

    // MARK: - Owner-Only Features

    @MainActor
    func testDecideAssigneeButton() throws {
        // 担当者決定ボタン（オーナーのみ表示）
        let decideAssigneeButton = app.buttons[CommonAccessibilityIDs.homeDecideAssigneeButton]

        // オーナーでない場合はスキップ
        guard decideAssigneeButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("担当者決定ボタンが表示されていません（オーナーではない可能性）")
        }

        // ボタンが存在することを確認
        XCTAssertTrue(decideAssigneeButton.exists)
    }

    // MARK: - Group Selector Tests

    @MainActor
    func testGroupSelectorMenu() throws {
        // グループセレクタをタップ
        let groupSelector = app.descendants(matching: .any)[CommonAccessibilityIDs.homeGroupSelector]
        UITestHelper.assertElementExists(groupSelector)
        groupSelector.tap()

        // メニューが表示されることを確認（グループ作成ボタンの存在で判定）
        let createGroupMenuItem = app.descendants(matching: .any)[CommonAccessibilityIDs.homeCreateGroupMenuItem]
        UITestHelper.assertElementExists(createGroupMenuItem, timeout: 3, message: "グループセレクタメニューが開きませんでした")

        // メニューを閉じる（画面外をタップ）
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).tap()
    }
}
