import Foundation
import StoreKit

/// アプリ情報を取得するサービス
/// バージョン、ビルド番号、初回インストール日時などを提供
protocol AppInfoServiceProtocol: Sendable {
    /// アプリのバージョン番号（例: "1.0.0"）
    var appVersion: String { get }

    /// アプリのビルド番号（例: "42"）
    var buildNumber: String { get }

    /// 初回インストール日時を取得
    /// - Returns: インストール日時。取得できない場合はnil
    func getOriginalPurchaseDate() async -> Date?
}

/// アプリ情報サービスの実装
final class AppInfoService: AppInfoServiceProtocol {
    static let shared = AppInfoService()

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    var appVersion: String {
        bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明"
    }

    var buildNumber: String {
        bundle.infoDictionary?["CFBundleVersion"] as? String ?? "不明"
    }

    func getOriginalPurchaseDate() async -> Date? {
        // App Store からのインストール日時を取得
        // TestFlightやApp Storeからインストールした場合に取得可能

        // currentEntitlementsを使用してApp Storeのトランザクションを確認
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                return transaction.originalPurchaseDate
            }
        }

        // トランザクションがない場合はアプリのインストール日時を取得（開発時フォールバック）
        return getDocumentsDirectoryCreationDate()
    }

    /// ドキュメントディレクトリの作成日時を取得（フォールバック用）
    private func getDocumentsDirectoryCreationDate() -> Date? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: documentsPath.path)
            return attributes[.creationDate] as? Date
        } catch {
            return nil
        }
    }
}
