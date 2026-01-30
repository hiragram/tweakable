//
//  TweakableApp.swift
//  Tweakable
//
//  Created by hiragram on 2025/12/13.
//

import SwiftUI
import AppCore

@main
struct TweakableApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// UIテストモードかどうか
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    /// UIテストのモック動作モード
    private var mockBehavior: MockRecipeExtractionService.MockBehavior {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--mock-extraction-error") {
            return .extractionError
        } else if args.contains("--mock-substitution-error") {
            return .substitutionError
        }
        return .success
    }

    var body: some Scene {
        WindowGroup {
            // バックエンドなしのスタンドアロンモード
            if isUITesting {
                RootView(recipeExtractionService: MockRecipeExtractionService(behavior: mockBehavior))
            } else {
                RootView()
            }
        }
    }
}
