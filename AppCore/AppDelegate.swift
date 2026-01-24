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
        // TODO: FCMトークンをSupabaseに保存する処理を追加
        // 実装方法:
        //   1. SupabaseStorageService.saveProfile() でprofiles.fcm_tokenを更新
        //   2. AppStoreからcurrentUserIDを取得して保存
        // 関連: Phase 4.1（FCM設定）完了後に実装
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
        // FCMからの通知を処理
        // TODO: Supabase/FCM通知の処理を追加
        // 実装内容:
        //   1. userInfo["notification_type"]で通知タイプを判定
        //   2. 担当者割り当て通知 → AppStoreに通知してスケジュール再フェッチ
        //   3. 参加リクエスト通知 → グループ情報を再フェッチ
        //   4. 参加承認通知 → グループ情報を再フェッチ
        // 関連: Phase 4.2（Database Webhooks + Edge Functions）完了後に実装
        completionHandler(.noData)
    }

    // MARK: - Quick Actions (Home Screen Shortcuts)

    public func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        switch shortcutItem.type {
        case "app.hiragram.Okumuka.debugMenu":
            NotificationCenter.default.post(name: Self.debugMenuShortcutNotification, object: nil)
            completionHandler(true)
        default:
            completionHandler(false)
        }
    }
}
