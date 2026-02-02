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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    /// UIテスト用: オンボーディングを強制的にスキップするフラグ
    private let forceSkipOnboarding: Bool

    /// オンボーディングを表示すべきかどうか
    private var shouldShowOnboarding: Bool {
        !forceSkipOnboarding && !hasCompletedOnboarding
    }

    #if DEBUG
    @State private var showDebugMenu = false
    #endif

    public init(
        recipeExtractionService: (any RecipeExtractionServiceProtocol)? = nil,
        recipePersistenceService: (any RecipePersistenceServiceProtocol)? = nil,
        mockPremium: Bool = false,
        skipOnboarding: Bool = false
    ) {
        self.forceSkipOnboarding = skipOnboarding

        // UIテスト用: mockPremiumがtrueの場合はMockRevenueCatServiceを使用
        let revenueCatService: any RevenueCatServiceProtocol = mockPremium
            ? MockRevenueCatService(isPremium: true)
            : RevenueCatService()

        _store = State(initialValue: AppStore(
            recipeExtractionService: recipeExtractionService,
            recipePersistenceService: recipePersistenceService,
            revenueCatService: revenueCatService
        ))
    }

    public var body: some View {
        content
            .onAppear {
                store.send(.boot)
            }
            #if DEBUG
            .onReceive(NotificationCenter.default.publisher(
                for: AppDelegate.debugMenuShortcutNotification
            )) { _ in
                showDebugMenu = true
            }
            .sheet(isPresented: $showDebugMenu) {
                DebugMenuView(store: store)
            }
            #endif
    }

    @ViewBuilder
    private var content: some View {
        if shouldShowOnboarding {
            OnboardingView(onComplete: {
                hasCompletedOnboarding = true
            })
        } else {
            RecipeHomeContainerView(store: store)
        }
    }
}

#Preview {
    RootView()
}
