import SwiftUI

/// EmailInputViewとStoreを接続するContainerView
struct EmailInputContainerView: View {
    let store: AppStore

    var body: some View {
        EmailInputView(
            email: store.state.auth.email,
            isSending: store.state.auth.isSendingOTP,
            errorMessage: store.state.auth.errorMessage,
            onEmailChanged: { email in
                store.send(.auth(.updateEmail(email)))
            },
            onSendOTP: {
                store.send(.auth(.sendOTP))
            }
        )
    }
}
