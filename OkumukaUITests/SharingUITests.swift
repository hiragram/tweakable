//
//  SharingUITests.swift
//  OkumukaUITests
//

import XCTest

final class SharingUITests: XCTestCase {
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

    // MARK: - Invite Member Tests

    @MainActor
    func testInviteMemberViewElements() throws {
        // 設定画面を開く
        UITestHelper.openSettings(app: app)

        // グループ設定を開く（オーナーのみ）
        let groupSettingsButton = app.buttons[CommonAccessibilityIDs.settingsGroupSettingsButton]
        guard groupSettingsButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("グループ設定ボタンが表示されていません（オーナーではない可能性）")
        }
        groupSettingsButton.tap()

        // メンバー招待を開く
        let inviteMemberButton = app.buttons[CommonAccessibilityIDs.groupSettingsInviteMemberButton]
        UITestHelper.assertElementExists(inviteMemberButton)
        inviteMemberButton.tap()

        // 閉じるボタンの存在確認（常に表示）
        let closeButton = app.buttons[CommonAccessibilityIDs.inviteMemberCloseButton]
        UITestHelper.assertElementExists(closeButton)

        // 閉じる
        closeButton.tap()

        // グループ設定に戻る
        UITestHelper.swipeBack(app: app)
    }

    // MARK: - Join Request List Tests

    @MainActor
    func testJoinRequestListViewElements() throws {
        // 設定画面を開く
        UITestHelper.openSettings(app: app)

        // グループ設定を開く（オーナーのみ）
        let groupSettingsButton = app.buttons[CommonAccessibilityIDs.settingsGroupSettingsButton]
        guard groupSettingsButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("グループ設定ボタンが表示されていません（オーナーではない可能性）")
        }
        groupSettingsButton.tap()

        // 参加リクエストボタンを確認（保留中のリクエストがある場合のみ表示）
        let joinRequestsButton = app.buttons[CommonAccessibilityIDs.groupSettingsJoinRequestsButton]
        guard joinRequestsButton.waitForExistence(timeout: 3) else {
            // 保留中の参加リクエストがない場合はスキップ
            throw XCTSkip("参加リクエストボタンが表示されていません（保留中のリクエストがない可能性）")
        }
        joinRequestsButton.tap()

        // 閉じるボタンの存在確認
        let closeButton = app.buttons[CommonAccessibilityIDs.joinRequestListCloseButton]
        UITestHelper.assertElementExists(closeButton)

        // 閉じる
        closeButton.tap()

        // グループ設定に戻る
        UITestHelper.swipeBack(app: app)
    }
}
