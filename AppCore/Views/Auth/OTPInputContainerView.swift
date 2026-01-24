import SwiftUI

/// OTPInputViewとStoreを接続するContainerView
struct OTPInputContainerView: View {
    let store: AppStore
    let email: String

    var body: some View {
        OTPInputView(
            email: email,
            otp: store.state.auth.otp,
            isVerifying: store.state.auth.isVerifyingOTP,
            errorMessage: store.state.auth.errorMessage,
            onOTPChanged: { otp in
                store.send(.auth(.updateOTP(otp)))
            },
            onVerify: {
                store.send(.auth(.verifyOTP))
            },
            onResend: {
                store.send(.auth(.sendOTP))
            },
            onBack: {
                // ログイン画面に戻る
                store.send(.setScreenState(.login))
            }
        )
    }
}
