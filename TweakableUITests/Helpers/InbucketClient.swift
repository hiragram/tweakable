//
//  InbucketClient.swift
//  TweakableUITests
//
//  Inbucket REST APIクライアント（OTPメール取得用）

import Foundation

/// Inbucket REST APIクライアント
enum InbucketClient {
    // MARK: - Types

    /// メールボックス内のメッセージヘッダー
    struct MessageHeader: Decodable {
        let id: String
        let from: String
        let to: [String]
        let subject: String
        let date: String
        let size: Int
    }

    /// メッセージ本文
    struct MessageBody: Decodable {
        let text: String
        let html: String
    }

    /// メッセージ詳細
    struct Message: Decodable {
        let mailbox: String
        let id: String
        let from: String
        let subject: String
        let date: String
        let body: MessageBody
    }

    // MARK: - Configuration

    /// ローカルSupabaseのInbucketポートを取得
    /// .supabase-local-port ファイルからAPI PORTを読み取り、+4してInbucket PORTを計算
    static func getInbucketPort() -> Int {
        let portFilePath = getProjectRootPath() + "/.supabase-local-port"

        guard let portString = try? String(contentsOfFile: portFilePath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines),
              let apiPort = Int(portString) else {
            // デフォルトポート（worktree名が"okumuka"の場合の計算値に近い値）
            return 54325
        }

        // Inbucket PORT = API PORT + 4
        return apiPort + 4
    }

    /// プロジェクトルートパスを取得
    private static func getProjectRootPath() -> String {
        // UIテスト実行時は、テストバンドルからプロジェクトルートを逆算
        // XCUIApplication経由で実行されるため、環境変数やカレントディレクトリは使えない
        // 代わりに、既知のパスパターンで推測する

        // まず環境変数を確認
        if let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] {
            return srcRoot
        }

        // カレントディレクトリから探索
        let fileManager = FileManager.default
        var currentPath = fileManager.currentDirectoryPath

        // .supabase-local-port が見つかるまで親ディレクトリを辿る
        for _ in 0..<10 {
            let portFilePath = currentPath + "/.supabase-local-port"
            if fileManager.fileExists(atPath: portFilePath) {
                return currentPath
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }

        // 見つからない場合は一般的なworktreeパスを試す
        let homeDir = NSHomeDirectory()
        let possiblePaths = [
            "\(homeDir)/Development/okumuka/worktrees/mimp-gocart-ticked",
            "\(homeDir)/Development/okumuka",
        ]

        for path in possiblePaths {
            if fileManager.fileExists(atPath: path + "/.supabase-local-port") {
                return path
            }
        }

        return fileManager.currentDirectoryPath
    }

    /// Inbucket APIのベースURL
    static var baseURL: String {
        "http://localhost:\(getInbucketPort())"
    }

    // MARK: - API Methods

    /// Inbucketが起動しているかチェック
    static func isAvailable() async -> Bool {
        do {
            let url = URL(string: "\(baseURL)/api/v1/monitor")!
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }

    /// メールボックスのメッセージ一覧を取得
    static func getMailbox(email: String) async throws -> [MessageHeader] {
        let mailboxName = extractMailboxName(from: email)
        let url = URL(string: "\(baseURL)/api/v1/mailbox/\(mailboxName)")!

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw InbucketError.apiError("Failed to fetch mailbox")
        }

        return try JSONDecoder().decode([MessageHeader].self, from: data)
    }

    /// 特定のメッセージを取得
    static func getMessage(email: String, messageId: String) async throws -> Message {
        let mailboxName = extractMailboxName(from: email)
        let url = URL(string: "\(baseURL)/api/v1/mailbox/\(mailboxName)/\(messageId)")!

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw InbucketError.apiError("Failed to fetch message")
        }

        return try JSONDecoder().decode(Message.self, from: data)
    }

    /// メールボックスをクリア
    static func clearMailbox(email: String) async throws {
        let mailboxName = extractMailboxName(from: email)
        let url = URL(string: "\(baseURL)/api/v1/mailbox/\(mailboxName)")!

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw InbucketError.apiError("Failed to clear mailbox")
        }
    }

    // MARK: - OTP Extraction

    /// 最新のOTPメールからOTPコードを取得
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - timeout: タイムアウト（秒）
    ///   - pollInterval: ポーリング間隔（秒）
    /// - Returns: OTPコード（6桁の数字）
    static func getOTP(
        for email: String,
        timeout: TimeInterval = 30,
        pollInterval: TimeInterval = 1
    ) async throws -> String {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            do {
                let messages = try await getMailbox(email: email)

                // 最新のメッセージを取得
                if let latestMessage = messages.last {
                    let message = try await getMessage(email: email, messageId: latestMessage.id)

                    // テキスト本文からOTPを抽出
                    if let otp = extractOTP(from: message.body.text) {
                        return otp
                    }

                    // HTML本文からOTPを抽出
                    if let otp = extractOTP(from: message.body.html) {
                        return otp
                    }
                }
            } catch {
                // エラーの場合は再試行
            }

            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }

        throw InbucketError.timeout("OTP email not received within \(timeout) seconds")
    }

    // MARK: - Private Helpers

    /// メールアドレスからメールボックス名を抽出（@より前の部分）
    /// URLパスで使用するためパーセントエンコーディングを適用
    private static func extractMailboxName(from email: String) -> String {
        let localPart = email.components(separatedBy: "@").first ?? email
        return localPart.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? localPart
    }

    /// テキストからOTPコード（6桁の数字）を抽出
    private static func extractOTP(from text: String) -> String? {
        // 6桁の数字を探す
        let pattern = "\\b(\\d{6})\\b"

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                  in: text,
                  range: NSRange(text.startIndex..., in: text)
              ),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[range])
    }

    // MARK: - Testable Methods (for unit tests)

    /// テスト用: extractOTPの公開ラッパー
    static func testableExtractOTP(from text: String) -> String? {
        extractOTP(from: text)
    }

    /// テスト用: extractMailboxNameの公開ラッパー
    static func testableExtractMailboxName(from email: String) -> String {
        extractMailboxName(from: email)
    }

    // MARK: - Errors

    enum InbucketError: Error, LocalizedError {
        case apiError(String)
        case timeout(String)

        var errorDescription: String? {
            switch self {
            case .apiError(let message): return "Inbucket API Error: \(message)"
            case .timeout(let message): return "Timeout: \(message)"
            }
        }
    }
}
