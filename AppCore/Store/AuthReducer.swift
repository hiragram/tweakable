import Foundation

/// 認証機能のReducer（純粋関数）
public enum AuthReducer {
    /// 状態を更新する純粋関数
    public static func reduce(state: inout AuthUIState, action: AuthAction) {
        switch action {
        // MARK: - Session

        case .restoreSession:
            // 副作用のみ（Storeで処理）
            break

        case .sessionRestored:
            // ScreenStateの更新はAppReducerで処理
            break

        // MARK: - OTP Flow

        case .updateEmail(let email):
            state.email = email

        case .sendOTP:
            // 副作用のみ（Storeで処理）
            break

        case .sendingOTP:
            state.isSendingOTP = true
            state.errorMessage = nil

        case .otpSent(let email):
            state.isSendingOTP = false
            state.otpSent = true
            state.email = email

        case .updateOTP(let otp):
            state.otp = otp

        case .verifyOTP:
            // 副作用のみ（Storeで処理）
            break

        case .verifyingOTP:
            state.isVerifyingOTP = true
            state.errorMessage = nil

        case .otpVerified(let userID, let isNewUser):
            state.isVerifyingOTP = false
            state.authenticatedUserID = userID
            state.isNewUser = isNewUser
            // OTPと入力データをクリア
            state.otp = ""

        // MARK: - Logout

        case .logout:
            // 副作用のみ（Storeで処理）
            break

        case .loggedOut:
            // 状態をリセット
            state = AuthUIState()

        // MARK: - Error

        case .errorOccurred(let message):
            state.errorMessage = message
            state.isSendingOTP = false
            state.isVerifyingOTP = false

        case .clearError:
            state.errorMessage = nil

        // MARK: - User Data Loading (Supabase)

        case .loadUserData:
            // 副作用のみ（Storeで処理）
            break

        case .userDataLoaded:
            // ScreenStateの更新はAppReducerで処理
            break
        }
    }
}
