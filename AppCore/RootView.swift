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

    #if DEBUG
    @State private var showDebugMenu = false
    #endif

    public init(
        recipeExtractionService: (any RecipeExtractionServiceProtocol)? = nil,
        recipePersistenceService: (any RecipePersistenceServiceProtocol)? = nil,
        mockPremium: Bool = false
    ) {
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
        RecipeHomeContainerView(store: store)
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
            .fullScreenCover(isPresented: .init(
                get: { !hasCompletedOnboarding },
                set: { if !$0 { hasCompletedOnboarding = true } }
            )) {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
            }
    }
}

#Preview {
    RootView()
}
