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

    var body: some Scene {
        WindowGroup {
            // バックエンドなしのスタンドアロンモード
            RootView()
        }
    }
}
