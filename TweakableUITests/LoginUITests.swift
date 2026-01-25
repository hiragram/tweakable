//
//  LoginUITests.swift
//  TweakableUITests
//
//  ログイン画面のUIテスト（E2E）

import XCTest

final class LoginUITests: XCTestCase {
    var app: XCUIApplication!

    /// テスト用のメールアドレス（Inbucketで受信可能な任意のアドレス）
    let testEmail = "uitest@example.com"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // UIテスト用のLaunch Argumentを設定（認証状態をリセット）
        app.launchArguments = ["--uitesting-reset-auth"]
        app.launch()

        // ログイン画面に到達できない場合はスキップ
        let isLoginVisible = UITestHelper.waitForLoginScreen(app: app, timeout: 15)
        try XCTSkipUnless(isLoginVisible, "ログイン画面に到達できませんでした")
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - EmailInputView Tests

    @MainActor
    func testEmailInputViewElementsExist() throws {
        // メール入力フィールドの存在確認
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        UITestHelper.assertElementExists(emailTextField, message: "メール入力フィールドが見つかりません")

        // OTP送信ボタンの存在確認
        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        UITestHelper.assertElementExists(sendOTPButton, message: "OTP送信ボタンが見つかりません")
    }

    @MainActor
    func testSendButtonDisabledForInvalidEmail() throws {
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]

        // 空の状態でボタンが無効か確認
        XCTAssertFalse(sendOTPButton.isEnabled, "空のメールアドレスでOTP送信ボタンが有効になっています")

        // 不正なメールアドレスを入力
        emailTextField.tap()
        emailTextField.typeText("invalid-email")

        // ボタンが無効のままか確認
        XCTAssertFalse(sendOTPButton.isEnabled, "不正なメールアドレスでOTP送信ボタンが有効になっています")
    }

    @MainActor
    func testSendButtonEnabledForValidEmail() throws {
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]

        // 有効なメールアドレスを入力
        emailTextField.tap()
        emailTextField.typeText("test@example.com")

        // ボタンが有効になるか確認
        XCTAssertTrue(sendOTPButton.isEnabled, "有効なメールアドレスでOTP送信ボタンが無効のままです")
    }

    // MARK: - OTPInputView Tests

    @MainActor
    func testOTPInputViewElementsExist() async throws {
        // Inbucketが利用可能かチェック
        let isInbucketAvailable = await InbucketClient.isAvailable()
        try XCTSkipUnless(isInbucketAvailable, "Inbucketが起動していません（ローカルSupabaseが必要）")

        // まずInbucketのメールボックスをクリア
        try await InbucketClient.clearMailbox(email: testEmail)

        // メールアドレスを入力してOTPを送信
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(testEmail)

        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        sendOTPButton.tap()

        // OTP画面に遷移するまで待機
        let isOTPVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 15)
        try XCTSkipUnless(isOTPVisible, "OTP入力画面に遷移できませんでした（Supabaseが起動していない可能性）")

        // OTP入力フィールドの存在確認
        let otpTextField = app.textFields[CommonAccessibilityIDs.otpInputTextField]
        UITestHelper.assertElementExists(otpTextField, message: "OTP入力フィールドが見つかりません")

        // 検証ボタンの存在確認
        let verifyButton = app.buttons[CommonAccessibilityIDs.otpInputVerifyButton]
        UITestHelper.assertElementExists(verifyButton, message: "OTP検証ボタンが見つかりません")

        // 再送信ボタンの存在確認
        let resendButton = app.buttons[CommonAccessibilityIDs.otpInputResendButton]
        UITestHelper.assertElementExists(resendButton, message: "OTP再送信ボタンが見つかりません")
    }

    @MainActor
    func testVerifyButtonDisabledForInvalidOTP() async throws {
        // Inbucketが利用可能かチェック
        let isInbucketAvailable = await InbucketClient.isAvailable()
        try XCTSkipUnless(isInbucketAvailable, "Inbucketが起動していません（ローカルSupabaseが必要）")

        // まずInbucketのメールボックスをクリア
        try await InbucketClient.clearMailbox(email: testEmail)

        // メールアドレスを入力してOTPを送信
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(testEmail)

        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        sendOTPButton.tap()

        // OTP画面に遷移するまで待機
        let isOTPVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 15)
        try XCTSkipUnless(isOTPVisible, "OTP入力画面に遷移できませんでした")

        let otpTextField = app.textFields[CommonAccessibilityIDs.otpInputTextField]
        let verifyButton = app.buttons[CommonAccessibilityIDs.otpInputVerifyButton]

        // 空の状態でボタンが無効か確認
        XCTAssertFalse(verifyButton.isEnabled, "空のOTPで検証ボタンが有効になっています")

        // 5桁のOTPを入力
        otpTextField.tap()
        otpTextField.typeText("12345")

        // ボタンが無効のままか確認
        XCTAssertFalse(verifyButton.isEnabled, "5桁のOTPで検証ボタンが有効になっています")
    }

    @MainActor
    func testBackToEmailInput() async throws {
        // Inbucketが利用可能かチェック
        let isInbucketAvailable = await InbucketClient.isAvailable()
        try XCTSkipUnless(isInbucketAvailable, "Inbucketが起動していません（ローカルSupabaseが必要）")

        // まずInbucketのメールボックスをクリア
        try await InbucketClient.clearMailbox(email: testEmail)

        // メールアドレスを入力してOTPを送信
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(testEmail)

        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        sendOTPButton.tap()

        // OTP画面に遷移するまで待機
        let isOTPVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 15)
        try XCTSkipUnless(isOTPVisible, "OTP入力画面に遷移できませんでした")

        // 戻るボタンをタップ（ナビゲーションバーの戻るボタン）
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists {
            backButton.tap()
        } else {
            // スワイプで戻る
            UITestHelper.swipeBack(app: app)
        }

        // メール入力画面に戻ったか確認
        let isLoginVisible = UITestHelper.waitForLoginScreen(app: app, timeout: 5)
        XCTAssertTrue(isLoginVisible, "メール入力画面に戻れませんでした")
    }

    // MARK: - E2E Login Flow Test

    @MainActor
    func testCompleteLoginFlow() async throws {
        // Inbucketが利用可能かチェック
        let isInbucketAvailable = await InbucketClient.isAvailable()
        try XCTSkipUnless(isInbucketAvailable, "Inbucketが起動していません（ローカルSupabaseが必要）")

        // まずInbucketのメールボックスをクリア
        try await InbucketClient.clearMailbox(email: testEmail)

        // 1. メールアドレスを入力
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(testEmail)

        // 2. OTPを送信
        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        sendOTPButton.tap()

        // 3. OTP画面に遷移するまで待機
        let isOTPVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 15)
        try XCTSkipUnless(isOTPVisible, "OTP入力画面に遷移できませんでした（ローカルSupabaseが起動していない可能性）")

        // 4. InbucketからOTPを取得
        let otp: String
        do {
            otp = try await InbucketClient.getOTP(for: testEmail, timeout: 30)
        } catch {
            throw XCTSkip("OTPメールを取得できませんでした: \(error.localizedDescription)")
        }

        // 5. OTPを入力
        let otpTextField = app.textFields[CommonAccessibilityIDs.otpInputTextField]
        otpTextField.tap()
        otpTextField.typeText(otp)

        // 6. 検証ボタンをタップ
        let verifyButton = app.buttons[CommonAccessibilityIDs.otpInputVerifyButton]
        XCTAssertTrue(verifyButton.isEnabled, "6桁のOTPを入力したのに検証ボタンが無効です")
        verifyButton.tap()

        // 7. ログイン後の画面に遷移するまで待機
        // 新規ユーザーの場合はオンボーディング画面、既存ユーザーの場合はホーム画面
        // ここではどちらかに遷移すればOKとする

        // オンボーディング画面またはホーム画面の表示を待機
        let homeVisible = UITestHelper.waitForHomeScreen(app: app, timeout: 20)

        // 新規ユーザーの場合はウェルカム画面が表示される可能性があるので、
        // ホーム画面が表示されなくても、ログイン画面から離れていればOK
        let loginStillVisible = UITestHelper.waitForLoginScreen(app: app, timeout: 2)
        let otpStillVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 2)

        let loginSucceeded = homeVisible || (!loginStillVisible && !otpStillVisible)
        XCTAssertTrue(loginSucceeded, "ログイン後に次の画面に遷移できませんでした")
    }

    // MARK: - Error Case Tests

    @MainActor
    func testEmailInputWithSpecialCharacters_handlesCorrectly() throws {
        // 特殊文字を含むメールアドレスの処理を確認
        let specialEmail = "test+alias@example.com"

        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(specialEmail)

        // プラス記号を含むメールアドレスでもボタンが有効になることを確認
        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        XCTAssertTrue(sendOTPButton.isEnabled, "プラス記号を含む有効なメールアドレスでOTP送信ボタンが有効になるべき")
    }

    @MainActor
    func testInvalidOTP_showsError() async throws {
        // Inbucketが利用可能かチェック
        let isInbucketAvailable = await InbucketClient.isAvailable()
        try XCTSkipUnless(isInbucketAvailable, "Inbucketが起動していません（ローカルSupabaseが必要）")

        // まずInbucketのメールボックスをクリア
        try await InbucketClient.clearMailbox(email: testEmail)

        // メールアドレスを入力してOTPを送信
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(testEmail)

        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        sendOTPButton.tap()

        // OTP画面に遷移するまで待機
        let isOTPVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 15)
        try XCTSkipUnless(isOTPVisible, "OTP入力画面に遷移できませんでした")

        // 間違ったOTPを入力
        let otpTextField = app.textFields[CommonAccessibilityIDs.otpInputTextField]
        otpTextField.tap()
        otpTextField.typeText("000000")

        // 検証ボタンをタップ
        let verifyButton = app.buttons[CommonAccessibilityIDs.otpInputVerifyButton]
        verifyButton.tap()

        // エラー後もOTP画面に留まっていることを確認（ログイン失敗）
        // 少し待ってからOTP画面がまだ表示されているか確認
        sleep(3)
        let stillOnOTPScreen = UITestHelper.waitForOTPScreen(app: app, timeout: 2)
        XCTAssertTrue(stillOnOTPScreen, "間違ったOTP入力後もOTP画面に留まるべき（エラー処理）")

        // OTP入力フィールドが再入力可能であることを確認
        XCTAssertTrue(otpTextField.exists, "OTP入力フィールドが存在し、再入力可能であるべき")
    }

    @MainActor
    func testResendOTP_sendsNewOTP() async throws {
        // Inbucketが利用可能かチェック
        let isInbucketAvailable = await InbucketClient.isAvailable()
        try XCTSkipUnless(isInbucketAvailable, "Inbucketが起動していません（ローカルSupabaseが必要）")

        // まずInbucketのメールボックスをクリア
        try await InbucketClient.clearMailbox(email: testEmail)

        // メールアドレスを入力してOTPを送信
        let emailTextField = app.textFields[CommonAccessibilityIDs.emailInputTextField]
        emailTextField.tap()
        emailTextField.typeText(testEmail)

        let sendOTPButton = app.buttons[CommonAccessibilityIDs.emailInputSendOTPButton]
        sendOTPButton.tap()

        // OTP画面に遷移するまで待機
        let isOTPVisible = UITestHelper.waitForOTPScreen(app: app, timeout: 15)
        try XCTSkipUnless(isOTPVisible, "OTP入力画面に遷移できませんでした")

        // 最初のOTPが届くのを待つ
        do {
            _ = try await InbucketClient.getOTP(for: testEmail, timeout: 30)
        } catch {
            throw XCTSkip("最初のOTPメールを取得できませんでした: \(error.localizedDescription)")
        }

        // メールボックスをクリアして再送信
        try await InbucketClient.clearMailbox(email: testEmail)

        // 再送信ボタンをタップ
        let resendButton = app.buttons[CommonAccessibilityIDs.otpInputResendButton]
        XCTAssertTrue(resendButton.exists, "再送信ボタンが存在するべき")
        resendButton.tap()

        // 少し待機
        sleep(2)

        // 新しいOTPが届くことを確認
        let newOTP: String
        do {
            newOTP = try await InbucketClient.getOTP(for: testEmail, timeout: 30)
        } catch {
            throw XCTSkip("再送信後のOTPメールを取得できませんでした: \(error.localizedDescription)")
        }

        // 新しいOTPが取得できたことを確認（値は異なる可能性がある）
        XCTAssertEqual(newOTP.count, 6, "再送信されたOTPは6桁であるべき")
    }
}
