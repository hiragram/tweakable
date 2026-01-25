//
//  AppDelegate.swift
//  App
//
//  Created by hiragram on 2025/12/13.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseCrashlytics

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

        // プッシュ通知の登録
        registerForPushNotifications()

        return true
    }

    // MARK: - Push Notifications

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Push notification authorization error: \(error)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        // バックエンドなし - トークン保存は不要
    }

    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    // MARK: - Remote Notifications

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // バックエンドなし - リモート通知は使用しない
        completionHandler(.noData)
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
