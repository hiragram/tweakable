//
//  OnboardingUITests.swift
//  OkumukaUITests
//
//  Note: オンボーディング系のテストはアプリの初期状態に依存するため、
//  テスト実行条件が限定されます。通常のテスト実行時はスキップされることがあります。
//

import XCTest

// MARK: - Onboarding AccessibilityIDs
// Note: オンボーディング画面のViewはAppCore内部のみで使用されるため、
// UIテストからはAccessibilityID文字列リテラルでアクセスする

private enum OnboardingAccessibilityIDs {
    // NoGroupView
    static let noGroupCreateButton = "noGroup_button_createGroup"

    // WaitingForApprovalView
    static let waitingForApprovalReloadButton = "waitingForApproval_button_reload"

    // CreateGroupView
    static let createGroupCancelButton = "createGroup_button_cancel"
    static let createGroupNameTextField = "createGroup_textField_groupName"
    static let createGroupCreateButton = "createGroup_button_create"

    // WelcomeView
    static let welcomeUserNameTextField = "welcome_textField_userName"
    static let welcomeStartButton = "welcome_button_start"

    // ICloudRequiredView
    static let iCloudRequiredRetryButton = "iCloudRequired_button_retry"
    static let iCloudRequiredOpenSettingsButton = "iCloudRequired_button_openSettings"
}

final class OnboardingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - No Group View Tests

    @MainActor
    func testNoGroupViewElements() throws {
        // グループなし状態の画面を確認
        let createGroupButton = app.buttons[OnboardingAccessibilityIDs.noGroupCreateButton]

        // グループなし画面が表示されていない場合はスキップ
        guard createGroupButton.waitForExistence(timeout: 15) else {
            throw XCTSkip("グループなし画面が表示されていません（既にグループに参加済み、またはiCloud未サインイン）")
        }

        // ボタンの存在確認
        XCTAssertTrue(createGroupButton.exists)
    }

    // MARK: - Waiting For Approval View Tests

    @MainActor
    func testWaitingForApprovalViewElements() throws {
        // 承認待ち画面を確認
        let reloadButton = app.buttons[OnboardingAccessibilityIDs.waitingForApprovalReloadButton]

        // 承認待ち画面が表示されていない場合はスキップ
        guard reloadButton.waitForExistence(timeout: 15) else {
            throw XCTSkip("承認待ち画面が表示されていません（グループ未参加、または既に承認済み）")
        }

        // ボタンの存在確認
        XCTAssertTrue(reloadButton.exists)
    }

    // MARK: - Create Group View Tests

    @MainActor
    func testCreateGroupViewElements() throws {
        // まずNoGroupViewからCreateGroupViewを開く必要がある
        let createGroupButtonOnNoGroup = app.buttons[OnboardingAccessibilityIDs.noGroupCreateButton]

        // グループなし画面が表示されていない場合はスキップ
        guard createGroupButtonOnNoGroup.waitForExistence(timeout: 15) else {
            throw XCTSkip("グループなし画面が表示されていません（グループ作成画面にアクセスできません）")
        }

        createGroupButtonOnNoGroup.tap()

        // グループ作成画面の要素確認
        let cancelButton = app.buttons[OnboardingAccessibilityIDs.createGroupCancelButton]
        UITestHelper.assertElementExists(cancelButton)

        let groupNameTextField = app.textFields[OnboardingAccessibilityIDs.createGroupNameTextField]
        UITestHelper.assertElementExists(groupNameTextField)

        let createButton = app.buttons[OnboardingAccessibilityIDs.createGroupCreateButton]
        UITestHelper.assertElementExists(createButton)

        // キャンセルして戻る
        cancelButton.tap()
    }

    // MARK: - Welcome View Tests

    @MainActor
    func testWelcomeViewElements() throws {
        // ウェルカム画面を確認（初回起動時のみ表示）
        let userNameTextField = app.textFields[OnboardingAccessibilityIDs.welcomeUserNameTextField]

        // ウェルカム画面が表示されていない場合はスキップ
        guard userNameTextField.waitForExistence(timeout: 15) else {
            throw XCTSkip("ウェルカム画面が表示されていません（既にユーザー登録済み）")
        }

        // 要素確認
        XCTAssertTrue(userNameTextField.exists)

        let startButton = app.buttons[OnboardingAccessibilityIDs.welcomeStartButton]
        XCTAssertTrue(startButton.exists)
    }

    // MARK: - iCloud Required View Tests

    @MainActor
    func testICloudRequiredViewElements() throws {
        // iCloud未サインイン時の画面を確認
        let retryButton = app.buttons[OnboardingAccessibilityIDs.iCloudRequiredRetryButton]

        // iCloud必須画面が表示されていない場合はスキップ
        guard retryButton.waitForExistence(timeout: 15) else {
            throw XCTSkip("iCloud必須画面が表示されていません（iCloudサインイン済み）")
        }

        // 要素確認
        XCTAssertTrue(retryButton.exists)

        let openSettingsButton = app.buttons[OnboardingAccessibilityIDs.iCloudRequiredOpenSettingsButton]
        XCTAssertTrue(openSettingsButton.exists)
    }
}
