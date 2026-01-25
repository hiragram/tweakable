//
//  ScheduleUITests.swift
//  TweakableUITests
//

import XCTest

final class ScheduleUITests: XCTestCase {
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

    // MARK: - Weekly Schedule View Tests

    @MainActor
    func testWeeklyScheduleViewElements() throws {
        // スケジュール入力画面を開く
        UITestHelper.openScheduleInput(app: app)

        // 送信ボタンの存在確認
        let submitButton = app.buttons[CommonAccessibilityIDs.weeklyScheduleSubmitButton]
        UITestHelper.assertElementExists(submitButton)

        // 7日分の送り/迎えボタンの要素参照を事前にキャッシュ
        let dayButtons = (0..<7).map { dayIndex in
            (
                dropOff: app.buttons[CommonAccessibilityIDs.weeklyScheduleDropOffButton(dayIndex: dayIndex)],
                pickUp: app.buttons[CommonAccessibilityIDs.weeklySchedulePickUpButton(dayIndex: dayIndex)]
            )
        }

        for (dayIndex, buttons) in dayButtons.enumerated() {
            UITestHelper.assertElementExists(buttons.dropOff, message: "Day \(dayIndex) の送りボタンが見つかりません")
            UITestHelper.assertElementExists(buttons.pickUp, message: "Day \(dayIndex) の迎えボタンが見つかりません")
        }
    }

    @MainActor
    func testToggleDropOffStatus() throws {
        // スケジュール入力画面を開く
        UITestHelper.openScheduleInput(app: app)

        // 送りボタンをタップ（ステータスがトグルされる）
        let dropOffButton = app.buttons[CommonAccessibilityIDs.weeklyScheduleDropOffButton(dayIndex: 0)]
        UITestHelper.assertElementExists(dropOffButton)

        // タップ前の状態を記録（label or accessibilityValue で判定できる場合）
        dropOffButton.tap()

        // ボタンが存在し続けることを確認（クラッシュしないこと）
        XCTAssertTrue(dropOffButton.exists)
    }

    @MainActor
    func testTogglePickUpStatus() throws {
        // スケジュール入力画面を開く
        UITestHelper.openScheduleInput(app: app)

        // 迎えボタンをタップ（ステータスがトグルされる）
        let pickUpButton = app.buttons[CommonAccessibilityIDs.weeklySchedulePickUpButton(dayIndex: 0)]
        UITestHelper.assertElementExists(pickUpButton)

        pickUpButton.tap()

        // ボタンが存在し続けることを確認（クラッシュしないこと）
        XCTAssertTrue(pickUpButton.exists)
    }

    @MainActor
    func testSubmitButton() throws {
        // スケジュール入力画面を開く
        UITestHelper.openScheduleInput(app: app)

        // 送信ボタンの存在確認
        let submitButton = app.buttons[CommonAccessibilityIDs.weeklyScheduleSubmitButton]
        UITestHelper.assertElementExists(submitButton)

        // 送信ボタンがタップ可能かどうかは状態に依存するので、存在確認のみ
        XCTAssertTrue(submitButton.exists)
    }

    // MARK: - Assignment Picker Tests

    @MainActor
    func testAssignmentPickerViewElements() throws {
        // 担当者決定ボタン（オーナーのみ）
        let decideAssigneeButton = app.buttons[CommonAccessibilityIDs.homeDecideAssigneeButton]

        // オーナーでない場合はスキップ
        guard decideAssigneeButton.waitForExistence(timeout: 3) else {
            throw XCTSkip("担当者決定ボタンが表示されていません（オーナーではない可能性）")
        }

        decideAssigneeButton.tap()

        // 保存ボタンの存在確認
        let saveButton = app.buttons[CommonAccessibilityIDs.assignmentPickerSaveButton]
        UITestHelper.assertElementExists(saveButton)

        // 日付行の存在確認（少なくとも1つ）
        // 注: 同一AccessibilityIDを持つ複数要素が存在するため .firstMatch が必要
        let dayRow = app.descendants(matching: .any)[CommonAccessibilityIDs.assignmentPickerDayRow(dayIndex: 0)].firstMatch
        UITestHelper.assertElementExists(dayRow, message: "担当者選択画面の日付行が見つかりません")
    }
}
