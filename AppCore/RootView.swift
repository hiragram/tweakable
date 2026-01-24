//
//  RootView.swift
//  App
//
//  Created by hiragram on 2025/12/13.
//

import SwiftUI

/// アプリのルートビュー
public struct RootView: View {
    @State private var store: AppStore
    @State private var showDebugMenu = false

    private let theme = DesignSystem.default

    /// 招待受け入れシートを表示するか
    /// handleShareURL（外部URLからの起動）でのみ表示。設定画面等からの起動では各画面で表示。
    private var showAcceptInvitationSheet: Bool {
        store.state.sharing.pendingInvitationInfo != nil
    }

    public init(
        supabaseClient: (any SupabaseClientProtocol)? = nil,
        supabaseStorageService: (any SupabaseStorageServiceProtocol)? = nil,
        networkMonitor: (any NetworkMonitorProtocol)? = nil
    ) {
        _store = State(initialValue: AppStore(
            supabaseClient: supabaseClient,
            supabaseStorageService: supabaseStorageService,
            networkMonitor: networkMonitor ?? NetworkMonitor()
        ))
    }

    public var body: some View {
        Group {
            switch store.state.screenState {
            // MARK: - Supabase Auth States
            case .checkingAuth:
                LoadingView(message: "認証状態を確認中...")

            case .login:
                EmailInputContainerView(store: store)

            case .otpVerification(let email):
                OTPInputContainerView(store: store, email: email)

            case .onboarding:
                WelcomeView { name in
                    store.completeOnboarding(userName: name)
                }

            case .groupSetup:
                CreateGroupContainerView(
                    store: store,
                    onCancel: {
                        // Go back to onboarding
                        store.send(.setScreenState(.onboarding))
                    },
                    onComplete: {
                        // Go to main screen after group is created
                        store.send(.setScreenState(.main))
                    }
                )

            case .main:
                HomeContainerView(store: store)
            }
        }
        .onAppear {
            store.send(.boot)
        }
        .sheet(isPresented: .constant(showAcceptInvitationSheet)) {
            AcceptInvitationContainerView(
                store: store,
                onDismiss: {
                    store.send(.sharing(.resetAcceptInvitation))
                },
                onContinueToSchedule: {
                    store.send(.sharing(.resetAcceptInvitation))
                    // 参加完了後はメイン画面へ
                    store.send(.setScreenState(.main))
                }
            )
        }
        .overlay(alignment: .top) {
            if store.state.schedule.showSuccessToast {
                SuccessToast()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, theme.spacing.md)
            }
        }
        .animation(.easeOut(duration: 0.2), value: store.state.schedule.showSuccessToast)
        // MARK: - Debug Menu (Quick Action)
        .onReceive(NotificationCenter.default.publisher(for: AppDelegate.debugMenuShortcutNotification)) { _ in
            showDebugMenu = true
        }
        .sheet(isPresented: $showDebugMenu) {
            DebugMenuContainerView(onDismiss: { showDebugMenu = false })
        }
    }
}

#Preview("Onboarding") {
    RootView()
}
