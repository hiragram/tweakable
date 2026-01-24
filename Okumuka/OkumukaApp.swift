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
            // UserDefaultsに保存された環境設定を使用（未設定時はlocal）
            let env = SupabaseEnvironment.current
            RootView(
                supabaseClient: SupabaseClientWrapper(
                    supabaseURL: URL(string: env.url)!,
                    supabaseKey: env.apiKey
                ),
                supabaseStorageService: SupabaseStorageService(
                    supabaseURL: URL(string: env.url)!,
                    supabaseKey: env.apiKey
                )
            )
            #if DEBUG
            .onAppear {
                // デバッグビルド時に環境バッジを表示
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    EnvironmentBadgeWindowManager.shared.show(in: windowScene)
                }
            }
            #endif
        }
    }
}
