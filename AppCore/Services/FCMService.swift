//
//  FCMService.swift
//  AppCore
//
//  Created by Claude on 2026/01/12.
//

import Foundation
import FirebaseMessaging

/// FCMトークン管理のためのプロトコル
public protocol FCMServiceProtocol: Sendable {
    /// FCMトークンを取得する
    func getToken() async throws -> String

    /// トークン更新を監視し、更新時にコールバックを呼ぶ
    func observeTokenRefresh(_ handler: @escaping (String) -> Void)
}

/// FCMServiceのエラー
public enum FCMServiceError: Error, Sendable {
    case tokenNotAvailable
}

/// FCMService実装
public final class FCMService: NSObject, FCMServiceProtocol, @unchecked Sendable {

    private var tokenRefreshHandler: ((String) -> Void)?

    public override init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    public func getToken() async throws -> String {
        do {
            let token = try await Messaging.messaging().token()
            return token
        } catch {
            throw FCMServiceError.tokenNotAvailable
        }
    }

    public func observeTokenRefresh(_ handler: @escaping (String) -> Void) {
        tokenRefreshHandler = handler
    }
}

// MARK: - MessagingDelegate

extension FCMService: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        tokenRefreshHandler?(token)
    }
}
