//
//  UITestHelper.swift
//  OkumukaUITests
//

import XCTest

// MARK: - Common AccessibilityIDs

enum CommonAccessibilityIDs {
    // HomeView
    static let homeSettingsButton = "home_button_settings"
    static let homeEnterScheduleButton = "home_button_enterSchedule"
    static let homeGroupSelector = "home_menu_groupSelector"
    static let homeCreateGroupMenuItem = "home_menu_createGroup"
    static let homeDecideAssigneeButton = "home_button_decideAssignee"
    static let homeAddWeatherLocationButton = "home_button_addWeatherLocation"

    // SettingsView
    static let settingsDoneButton = "settings_button_done"
    static let settingsMyAssignmentsButton = "settings_button_myAssignments"
    static let settingsGroupSettingsButton = "settings_button_groupSettings"
    static let settingsMemberListButton = "settings_button_memberList"
    static let settingsAddLocationButton = "settings_button_addLocation"
    static let settingsAboutButton = "settings_button_about"

    // MyAssignmentsView
    static let myAssignmentsDoneButton = "myAssignments_button_done"

    // GroupSettingsView
    static let groupSettingsJoinRequestsButton = "groupSettings_button_joinRequests"
    static let groupSettingsInviteMemberButton = "groupSettings_button_inviteMember"
    static let groupSettingsWeekdaySettingsButton = "groupSettings_button_weekdaySettings"
    static let groupSettingsDeleteGroupButton = "groupSettings_button_deleteGroup"

    // WeekdaySettingsView
    static let weekdaySettingsDoneButton = "weekdaySettings_button_done"
    static func weekdaySettingsToggle(weekday: String) -> String {
        "weekdaySettings_toggle_\(weekday)"
    }

    // MemberListView
    static let memberListCloseButton = "memberList_button_close"

    // WeatherLocationEditView
    static let weatherLocationCancelButton = "weatherLocationEdit_button_cancel"
    static let weatherLocationSaveButton = "weatherLocationEdit_button_save"
    static let weatherLocationLabelTextField = "weatherLocationEdit_textField_label"
    static let weatherLocationDeleteButton = "weatherLocationEdit_button_delete"

    // AboutView
    static let aboutDoneButton = "about_button_done"
    static let aboutLicenseButton = "about_button_license"

    // WeeklyScheduleView
    static let weeklyScheduleSubmitButton = "weeklySchedule_button_submit"
    static func weeklyScheduleDropOffButton(dayIndex: Int) -> String {
        "weeklySchedule_button_dropOff_day\(dayIndex)"
    }
    static func weeklySchedulePickUpButton(dayIndex: Int) -> String {
        "weeklySchedule_button_pickUp_day\(dayIndex)"
    }

    // AssignmentPickerView
    static let assignmentPickerSaveButton = "assignmentPicker_button_save"
    static func assignmentPickerDayRow(dayIndex: Int) -> String {
        "assignmentPicker_row_day\(dayIndex)"
    }

    // InviteMemberView
    static let inviteMemberCloseButton = "inviteMember_button_close"
    static let inviteMemberCopyUrlButton = "inviteMember_button_copyUrl"
    static let inviteMemberShareButton = "inviteMember_button_share"

    // JoinRequestListView
    static let joinRequestListCloseButton = "joinRequestList_button_close"

    // EmailInputView (Login)
    static let emailInputTextField = "emailInput_textField_email"
    static let emailInputSendOTPButton = "emailInput_button_sendOTP"

    // OTPInputView (Login)
    static let otpInputTextField = "otpInput_textField_otp"
    static let otpInputVerifyButton = "otpInput_button_verify"
    static let otpInputResendButton = "otpInput_button_resend"
}

enum UITestHelper {
    /// ログイン画面（メール入力）が表示されるまで待機
    /// - Returns: ログイン画面に到達できたかどうか
    static func waitForLoginScreen(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        return emailTextField.waitForExistence(timeout: timeout)
    }

    /// OTP入力画面が表示されるまで待機
    /// - Returns: OTP画面に到達できたかどうか
    static func waitForOTPScreen(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        let otpTextField = app.textFields[CommonAccessibilityIDs.otpInputTextField]
        return otpTextField.waitForExistence(timeout: timeout)
    }

    /// ホーム画面が表示されるまで待機
    /// - Returns: ホーム画面に到達できたかどうか
    static func waitForHomeScreen(app: XCUIApplication, timeout: TimeInterval = 15) -> Bool {
        let settingsButton = app.buttons[CommonAccessibilityIDs.homeSettingsButton]
        return settingsButton.waitForExistence(timeout: timeout)
    }

    /// 設定画面を開く
    static func openSettings(app: XCUIApplication) {
        app.buttons[CommonAccessibilityIDs.homeSettingsButton].tap()
    }

    /// スケジュール入力画面を開く
    static func openScheduleInput(app: XCUIApplication) {
        app.buttons[CommonAccessibilityIDs.homeEnterScheduleButton].tap()
    }

    /// スワイプで前の画面に戻る
    static func swipeBack(app: XCUIApplication) {
        app.swipeRight()
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
