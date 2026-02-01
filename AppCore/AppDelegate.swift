//
//  AppDelegate.swift
//  App
//
//  Created by hiragram on 2025/12/13.
//

import UIKit
import FirebaseCore
import FirebaseCrashlytics
import RevenueCat

public class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Quick Actions Notifications

    /// デバッグメニューを開くQuick Actionが発火したときの通知
    public static let debugMenuShortcutNotification = Notification.Name("debugMenuShortcut")

    // MARK: - Application Lifecycle

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase初期化
        FirebaseApp.configure()

        // RevenueCat初期化
        configureRevenueCat()

        return true
    }

    // MARK: - RevenueCat

    private func configureRevenueCat() {
        #if DEBUG
        // DEBUGビルドでは DebugSettings から Store 設定を読み取る
        let apiKey: String
        if DebugSettings.shared.useTestStore {
            // Test Store API Key（開発用・サンドボックス環境）
            apiKey = "test_YVcYsAXzHheuOIqLwOkFOutfggp"
        } else {
            // App Store API Key（本番環境）
            apiKey = "appl_nLhBICTcjClkCJWfwFLtDkBTmai"
        }
        Purchases.logLevel = .debug
        #else
        // Production API Key（本番環境）
        let apiKey = "appl_nLhBICTcjClkCJWfwFLtDkBTmai"
        Purchases.logLevel = .error
        #endif
        Purchases.configure(withAPIKey: apiKey)
    }

    // MARK: - Quick Actions (Home Screen Shortcuts)

    public func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        switch shortcutItem.type {
        case "app.hiragram.Tweakable.debugMenu":
            NotificationCenter.default.post(name: Self.debugMenuShortcutNotification, object: nil)
            completionHandler(true)
        default:
            completionHandler(false)
        }
    }
}
