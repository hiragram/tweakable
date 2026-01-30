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

    var body: some Scene {
        WindowGroup {
            // バックエンドなしのスタンドアロンモード
            if isUITesting {
                RootView(recipeExtractionService: MockRecipeExtractionService())
            } else {
                RootView()
            }
        }
    }
}
