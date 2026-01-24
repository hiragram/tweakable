//
//  SettingsUITests.swift
//  OkumukaUITests
//

import XCTest

final class SettingsUITests: XCTestCase {
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

    // MARK: - Settings View Tests

    @MainActor
    func testSettingsViewElements() throws {
        UITestHelper.openSettings(app: app)

        // 設定画面の主要要素を確認
        let doneButton = app.buttons[CommonAccessibilityIDs.settingsDoneButton]
        UITestHelper.assertElementExists(doneButton)

        let myAssignmentsButton = app.buttons[CommonAccessibilityIDs.settingsMyAssignmentsButton]
        UITestHelper.assertElementExists(myAssignmentsButton)

        let memberListButton = app.buttons[CommonAccessibilityIDs.settingsMemberListButton]
        UITestHelper.assertElementExists(memberListButton)

        let aboutButton = app.buttons[CommonAccessibilityIDs.settingsAboutButton]
        UITestHelper.assertElementExists(aboutButton)

        // 閉じる
        doneButton.tap()
    }

    // MARK: - My Assignments Tests

    @MainActor
    func testMyAssignmentsView() throws {
        UITestHelper.openSettings(app: app)

        // 担当曜日設定画面を開く
        let myAssignmentsButton = app.buttons[CommonAccessibilityIDs.settingsMyAssignmentsButton]
        UITestHelper.assertElementExists(myAssignmentsButton)
        myAssignmentsButton.tap()

        // 完了ボタンの存在確認
        let doneButton = app.buttons[CommonAccessibilityIDs.myAssignmentsDoneButton]
        UITestHelper.assertElementExists(doneButton)

        // 戻る
        doneButton.tap()

        // 設定画面に戻ったことを確認
        let settingsDoneButton = app.buttons[CommonAccessibilityIDs.settingsDoneButton]
        UITestHelper.assertElementExists(settingsDoneButton)
    }

    // MARK: - Group Settings Tests (Owner Only)

    @MainActor
    func testGroupSettingsView() throws {
        UITestHelper.openSettings(app: app)

        // グループ設定ボタン（オーナーのみ表示）
        let groupSettingsButton = app.buttons[CommonAccessibilityIDs.settingsGroupSettingsButton]

        // オーナーでない場合はスキップ
        guard groupSettingsButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("グループ設定ボタンが表示されていません（オーナーではない可能性）")
        }

        groupSettingsButton.tap()

        // グループ設定画面の要素を確認
        let inviteMemberButton = app.buttons[CommonAccessibilityIDs.groupSettingsInviteMemberButton]
        UITestHelper.assertElementExists(inviteMemberButton)

        let weekdaySettingsButton = app.buttons[CommonAccessibilityIDs.groupSettingsWeekdaySettingsButton]
        UITestHelper.assertElementExists(weekdaySettingsButton)

        let deleteGroupButton = app.buttons[CommonAccessibilityIDs.groupSettingsDeleteGroupButton]
        UITestHelper.assertElementExists(deleteGroupButton)

        // 戻る
        UITestHelper.swipeBack(app: app)
    }

    @MainActor
    func testWeekdaySettingsView() throws {
        UITestHelper.openSettings(app: app)

        // グループ設定を開く
        let groupSettingsButton = app.buttons[CommonAccessibilityIDs.settingsGroupSettingsButton]
        guard groupSettingsButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("グループ設定ボタンが表示されていません（オーナーではない可能性）")
        }
        groupSettingsButton.tap()

        // 曜日設定を開く
        let weekdaySettingsButton = app.buttons[CommonAccessibilityIDs.groupSettingsWeekdaySettingsButton]
        UITestHelper.assertElementExists(weekdaySettingsButton)
        weekdaySettingsButton.tap()

        // 7つの曜日トグルの要素参照を事前にキャッシュ
        // 注: 同一AccessibilityIDを持つ複数要素が存在するため .firstMatch が必要
        let weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        let toggles = weekdays.map { weekday in
            app.descendants(matching: .any)[CommonAccessibilityIDs.weekdaySettingsToggle(weekday: weekday)].firstMatch
        }

        for (weekday, toggle) in zip(weekdays, toggles) {
            UITestHelper.assertElementExists(toggle, message: "\(weekday)のトグルが見つかりません")
        }

        // 完了ボタンの存在確認
        let doneButton = app.buttons[CommonAccessibilityIDs.weekdaySettingsDoneButton]
        UITestHelper.assertElementExists(doneButton)
        doneButton.tap()

        // グループ設定に戻る
        UITestHelper.swipeBack(app: app)
    }

    // MARK: - Member List Tests

    @MainActor
    func testMemberListView() throws {
        UITestHelper.openSettings(app: app)

        // メンバー一覧を開く
        let memberListButton = app.buttons[CommonAccessibilityIDs.settingsMemberListButton]
        UITestHelper.assertElementExists(memberListButton)
        memberListButton.tap()

        // 閉じるボタンの存在確認
        let closeButton = app.buttons[CommonAccessibilityIDs.memberListCloseButton]
        UITestHelper.assertElementExists(closeButton)

        // 閉じる
        closeButton.tap()

        // 設定画面に戻ったことを確認
        let settingsDoneButton = app.buttons[CommonAccessibilityIDs.settingsDoneButton]
        UITestHelper.assertElementExists(settingsDoneButton)
    }

    // MARK: - Weather Location Tests

    @MainActor
    func testWeatherLocationAddView() throws {
        UITestHelper.openSettings(app: app)

        // 天気地点追加ボタンを探す
        let addLocationButton = app.buttons[CommonAccessibilityIDs.settingsAddLocationButton]

        // 追加ボタンがない場合（既に2地点登録済み）はスキップ
        guard addLocationButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("天気地点追加ボタンが表示されていません（上限に達している可能性）")
        }

        addLocationButton.tap()

        // 天気地点編集画面の要素確認
        let cancelButton = app.buttons[CommonAccessibilityIDs.weatherLocationCancelButton]
        UITestHelper.assertElementExists(cancelButton)

        let saveButton = app.buttons[CommonAccessibilityIDs.weatherLocationSaveButton]
        UITestHelper.assertElementExists(saveButton)

        let labelTextField = app.textFields[CommonAccessibilityIDs.weatherLocationLabelTextField]
        UITestHelper.assertElementExists(labelTextField)

        // キャンセルして戻る
        cancelButton.tap()
    }

    // MARK: - About Tests

    @MainActor
    func testAboutView() throws {
        UITestHelper.openSettings(app: app)

        // アプリについてを開く
        let aboutButton = app.buttons[CommonAccessibilityIDs.settingsAboutButton]
        UITestHelper.assertElementExists(aboutButton)
        aboutButton.tap()

        // 要素確認
        let licenseButton = app.buttons[CommonAccessibilityIDs.aboutLicenseButton]
        UITestHelper.assertElementExists(licenseButton)

        let doneButton = app.buttons[CommonAccessibilityIDs.aboutDoneButton]
        UITestHelper.assertElementExists(doneButton)

        // 閉じる
        doneButton.tap()

        // 設定画面に戻ったことを確認
        let settingsDoneButton = app.buttons[CommonAccessibilityIDs.settingsDoneButton]
        UITestHelper.assertElementExists(settingsDoneButton)
    }
}
