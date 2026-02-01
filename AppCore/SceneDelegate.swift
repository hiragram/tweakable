//
//  SceneDelegate.swift
//  AppCore
//
//  Created by Claude on 2026/02/01.
//

import UIKit

#if DEBUG
public class SceneDelegate: NSObject, UIWindowSceneDelegate {

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // コールドローンチ時のQuick Action処理
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItem(shortcutItem)
        }
    }

    public func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        // ウォームローンチ時のQuick Action処理
        let handled = handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }

    @discardableResult
    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        switch shortcutItem.type {
        case "app.hiragram.Tweakable.debugMenu":
            // 少し遅延させて通知を投稿（UIが準備できるのを待つ）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(
                    name: AppDelegate.debugMenuShortcutNotification,
                    object: nil
                )
            }
            return true
        default:
            return false
        }
    }
}
#endif
