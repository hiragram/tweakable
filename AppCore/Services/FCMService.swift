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

    /// FCMトークンをSupabaseのprofilesテーブルに保存する
    func saveToken(_ token: String, userID: UUID) async throws

    /// トークン更新を監視し、更新時にコールバックを呼ぶ
    func observeTokenRefresh(_ handler: @escaping (String) -> Void)
}

/// FCMServiceのエラー
public enum FCMServiceError: Error, Sendable {
    case tokenNotAvailable
    case saveFailed(String)
}

/// FCMService実装
public final class FCMService: NSObject, FCMServiceProtocol, @unchecked Sendable {

    private let storageService: SupabaseStorageServiceProtocol
    private var tokenRefreshHandler: ((String) -> Void)?

    public init(storageService: SupabaseStorageServiceProtocol) {
        self.storageService = storageService
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

    public func saveToken(_ token: String, userID: UUID) async throws {
        do {
            try await storageService.saveFCMToken(token, userID: userID)
        } catch {
            throw FCMServiceError.saveFailed(error.localizedDescription)
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
