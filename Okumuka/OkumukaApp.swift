//
//  OkumukaApp.swift
//  Okumuka
//
//  Created by hiragram on 2025/12/13.
//

import SwiftUI
import AppCore

@main
struct OkumukaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // バックエンドなしのスタンドアロンモード
            RootView()
        }
    }
}
