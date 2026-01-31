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

    public init(
        recipeExtractionService: (any RecipeExtractionServiceProtocol)? = nil,
        mockPremium: Bool = false
    ) {
        // UIテスト用: mockPremiumがtrueの場合はMockRevenueCatServiceを使用
        let revenueCatService: any RevenueCatServiceProtocol = mockPremium
            ? MockRevenueCatService(isPremium: true)
            : RevenueCatService()

        _store = State(initialValue: AppStore(
            recipeExtractionService: recipeExtractionService,
            revenueCatService: revenueCatService
        ))
    }

    public var body: some View {
        RecipeHomeContainerView(store: store)
            .onAppear {
                store.send(.boot)
            }
    }
}

#Preview {
    RootView()
}
