import Testing
import Foundation
@testable import AppCore

@Suite
struct AuthReducerTests {

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = AuthUIState()

        #expect(state.email == "")
        #expect(state.otp == "")
        #expect(state.isSendingOTP == false)
        #expect(state.isVerifyingOTP == false)
        #expect(state.errorMessage == nil)
        #expect(state.otpSent == false)
        #expect(state.authenticatedUserID == nil)
        #expect(state.isNewUser == false)
    }

    // MARK: - Email Update Tests

    @Test
    func reduce_updateEmail_setsEmail() {
        var state = AuthUIState()

        AuthReducer.reduce(state: &state, action: .updateEmail("test@example.com"))

        #expect(state.email == "test@example.com")
    }

    @Test
    func reduce_updateEmail_updatesExistingEmail() {
        var state = AuthUIState()
        state.email = "old@example.com"

        AuthReducer.reduce(state: &state, action: .updateEmail("new@example.com"))

        #expect(state.email == "new@example.com")
    }

    @Test
    func reduce_updateEmail_clearsToEmptyString() {
        var state = AuthUIState()
        state.email = "test@example.com"

        AuthReducer.reduce(state: &state, action: .updateEmail(""))

        #expect(state.email == "")
    }

    // MARK: - OTP Sending Tests

    @Test
    func reduce_sendingOTP_setsSendingFlagAndClearsError() {
        var state = AuthUIState()
        state.errorMessage = "前回のエラー"

        AuthReducer.reduce(state: &state, action: .sendingOTP)

        #expect(state.isSendingOTP == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_otpSent_clearsSendingFlagAndSetsOtpSent() {
        var state = AuthUIState()
        state.isSendingOTP = true

        AuthReducer.reduce(state: &state, action: .otpSent(email: "user@example.com"))

        #expect(state.isSendingOTP == false)
        #expect(state.otpSent == true)
        #expect(state.email == "user@example.com")
    }

    @Test
    func reduce_otpSent_preservesEmailFromAction() {
        var state = AuthUIState()
        state.email = "different@example.com"
        state.isSendingOTP = true

        AuthReducer.reduce(state: &state, action: .otpSent(email: "correct@example.com"))

        #expect(state.email == "correct@example.com")
    }

    // MARK: - OTP Update Tests

    @Test
    func reduce_updateOTP_setsOTP() {
        var state = AuthUIState()

        AuthReducer.reduce(state: &state, action: .updateOTP("123456"))

        #expect(state.otp == "123456")
    }

    @Test
    func reduce_updateOTP_updatesExistingOTP() {
        var state = AuthUIState()
        state.otp = "111111"

        AuthReducer.reduce(state: &state, action: .updateOTP("222222"))

        #expect(state.otp == "222222")
    }

    // MARK: - OTP Verification Tests

    @Test
    func reduce_verifyingOTP_setsVerifyingFlagAndClearsError() {
        var state = AuthUIState()
        state.errorMessage = "前回のエラー"

        AuthReducer.reduce(state: &state, action: .verifyingOTP)

        #expect(state.isVerifyingOTP == true)
        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_otpVerified_setsAuthenticatedUserAndClearsOTP() {
        var state = AuthUIState()
        state.isVerifyingOTP = true
        state.otp = "123456"
        let userID = UUID()

        AuthReducer.reduce(state: &state, action: .otpVerified(userID: userID, isNewUser: false))

        #expect(state.isVerifyingOTP == false)
        #expect(state.authenticatedUserID == userID)
        #expect(state.isNewUser == false)
        #expect(state.otp == "")
    }

    @Test
    func reduce_otpVerified_setsIsNewUserTrue() {
        var state = AuthUIState()
        state.isVerifyingOTP = true
        let userID = UUID()

        AuthReducer.reduce(state: &state, action: .otpVerified(userID: userID, isNewUser: true))

        #expect(state.isNewUser == true)
        #expect(state.authenticatedUserID == userID)
    }

    // MARK: - Logout Tests

    @Test
    func reduce_loggedOut_resetsAllState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        state.otp = "123456"
        state.isSendingOTP = true
        state.isVerifyingOTP = true
        state.errorMessage = "エラー"
        state.otpSent = true
        state.authenticatedUserID = UUID()
        state.isNewUser = true

        AuthReducer.reduce(state: &state, action: .loggedOut)

        #expect(state.email == "")
        #expect(state.otp == "")
        #expect(state.isSendingOTP == false)
        #expect(state.isVerifyingOTP == false)
        #expect(state.errorMessage == nil)
        #expect(state.otpSent == false)
        #expect(state.authenticatedUserID == nil)
        #expect(state.isNewUser == false)
    }

    // MARK: - Error Handling Tests

    @Test
    func reduce_errorOccurred_setsErrorAndClearsLoadingFlags() {
        var state = AuthUIState()
        state.isSendingOTP = true
        state.isVerifyingOTP = true

        AuthReducer.reduce(state: &state, action: .errorOccurred("認証に失敗しました"))

        #expect(state.errorMessage == "認証に失敗しました")
        #expect(state.isSendingOTP == false)
        #expect(state.isVerifyingOTP == false)
    }

    @Test
    func reduce_errorOccurred_clearsOnlyIfFlagsWereSet() {
        var state = AuthUIState()
        // フラグが設定されていない状態

        AuthReducer.reduce(state: &state, action: .errorOccurred("エラー"))

        #expect(state.errorMessage == "エラー")
        #expect(state.isSendingOTP == false)
        #expect(state.isVerifyingOTP == false)
    }

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = AuthUIState()
        state.errorMessage = "何かのエラー"

        AuthReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }

    @Test
    func reduce_clearError_doesNothingWhenNoError() {
        var state = AuthUIState()
        // errorMessageがnilの状態

        AuthReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }

    // MARK: - Side Effect Only Actions Tests
    // これらのアクションは状態を変更しない（副作用のみ）

    @Test
    func reduce_restoreSession_doesNotChangeState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .restoreSession)

        #expect(state == originalState)
    }

    @Test
    func reduce_sessionRestored_doesNotChangeState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .sessionRestored(userID: UUID()))

        #expect(state == originalState)
    }

    @Test
    func reduce_sendOTP_doesNotChangeState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .sendOTP)

        #expect(state == originalState)
    }

    @Test
    func reduce_verifyOTP_doesNotChangeState() {
        var state = AuthUIState()
        state.otp = "123456"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .verifyOTP)

        #expect(state == originalState)
    }

    @Test
    func reduce_logout_doesNotChangeState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .logout)

        #expect(state == originalState)
    }

    @Test
    func reduce_loadUserData_doesNotChangeState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .loadUserData)

        #expect(state == originalState)
    }

    @Test
    func reduce_userDataLoaded_doesNotChangeState() {
        var state = AuthUIState()
        state.email = "test@example.com"
        let originalState = state

        AuthReducer.reduce(state: &state, action: .userDataLoaded(profile: nil, groups: []))

        #expect(state == originalState)
    }

    // MARK: - Edge Case Tests

    @Test
    func reduce_otpSent_afterError_clearsErrorImplicitly() {
        var state = AuthUIState()
        state.errorMessage = "前回のエラー"
        state.isSendingOTP = true

        // sendingOTPでエラーがクリアされる
        AuthReducer.reduce(state: &state, action: .sendingOTP)
        #expect(state.errorMessage == nil)

        // その後otpSentが呼ばれる
        AuthReducer.reduce(state: &state, action: .otpSent(email: "test@example.com"))
        #expect(state.errorMessage == nil)
        #expect(state.otpSent == true)
    }

    @Test
    func reduce_multipleEmailUpdates_keepsLatest() {
        var state = AuthUIState()

        AuthReducer.reduce(state: &state, action: .updateEmail("first@example.com"))
        AuthReducer.reduce(state: &state, action: .updateEmail("second@example.com"))
        AuthReducer.reduce(state: &state, action: .updateEmail("third@example.com"))

        #expect(state.email == "third@example.com")
    }

    @Test
    func reduce_errorAfterOtpSent_preservesOtpSentFlag() {
        var state = AuthUIState()
        state.otpSent = true
        state.isVerifyingOTP = true

        AuthReducer.reduce(state: &state, action: .errorOccurred("検証エラー"))

        #expect(state.otpSent == true)  // OTP送信済みフラグは保持される
        #expect(state.isVerifyingOTP == false)
        #expect(state.errorMessage == "検証エラー")
    }
}
