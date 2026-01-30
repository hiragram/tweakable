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

    /// 起動引数（一度だけ取得してキャッシュ）
    private let launchArguments = ProcessInfo.processInfo.arguments

    /// UIテストモードかどうか
    private var isUITesting: Bool {
        launchArguments.contains("--uitesting")
    }

    /// UIテストのモック動作モード
    ///
    /// 起動引数に応じてモックサービスの動作を制御:
    /// - `--mock-extraction-error`: レシピ抽出時にエラーを返す
    /// - `--mock-substitution-error`: 置き換え時にエラーを返す
    /// - なし: 正常動作
    private var mockBehavior: MockRecipeExtractionService.MockBehavior {
        if launchArguments.contains("--mock-extraction-error") {
            return .extractionError
        } else if launchArguments.contains("--mock-substitution-error") {
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
