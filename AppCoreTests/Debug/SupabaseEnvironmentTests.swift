//
//  SupabaseEnvironmentTests.swift
//  AppCoreTests
//
//  Created by Claude on 2026/01/14.
//

import Testing
import Foundation
@testable import AppCore

@Suite(.serialized)
struct SupabaseEnvironmentTests {

    // MARK: - Setup/Teardown

    init() {
        // テスト前にUserDefaultsをクリア
        UserDefaults.standard.removeObject(forKey: "supabaseEnvironment")
    }

    // MARK: - Default Value Tests

    @Test
    func current_fallbackBehavior_returnsLocal() {
        // 不正な値の場合、localがデフォルト
        UserDefaults.standard.set("invalid_environment", forKey: "supabaseEnvironment")
        #expect(SupabaseEnvironment.current == .local)

        // 空文字列の場合、localがデフォルト
        UserDefaults.standard.set("", forKey: "supabaseEnvironment")
        #expect(SupabaseEnvironment.current == .local)

        // nilの場合（removeObject）、localがデフォルト
        UserDefaults.standard.removeObject(forKey: "supabaseEnvironment")
        #expect(SupabaseEnvironment.current == .local)
    }

    // MARK: - Persistence Tests

    @Test
    func current_setAndGet_worksCorrectly() {
        // 設定と取得が正しく動作することを確認
        // 注意: このテストは他のテストと並列実行されるため、
        // 設定→即時取得の流れで検証する

        // production設定
        SupabaseEnvironment.current = .production
        #expect(SupabaseEnvironment.current == .production)

        // local設定
        SupabaseEnvironment.current = .local
        #expect(SupabaseEnvironment.current == .local)

        // 再度production設定
        SupabaseEnvironment.current = .production
        #expect(SupabaseEnvironment.current == .production)
    }

    // MARK: - URL Tests

    @Test
    func url_forLocal_returnsLocalhostWithDynamicPort() {
        let url = SupabaseEnvironment.local.url
        let expectedPort = Secrets.supabaseLocalPort

        #expect(url == "http://localhost:\(expectedPort)")
    }

    @Test
    func url_forProduction_returnsSecretsUrl() {
        let url = SupabaseEnvironment.production.url

        #expect(url == Secrets.supabaseProjectUrl)
    }

    // MARK: - API Key Tests

    @Test
    func apiKey_forLocal_returnsLocalKey() {
        let apiKey = SupabaseEnvironment.local.apiKey

        // ローカルSupabaseのデフォルトanon key（JWT形式）
        // JWTは header.payload.signature の形式
        #expect(apiKey.hasPrefix("eyJ"))
        let parts = apiKey.split(separator: ".")
        #expect(parts.count == 3, "JWT should have 3 parts separated by dots")
    }

    @Test
    func apiKey_forProduction_returnsSecretsKey() {
        let apiKey = SupabaseEnvironment.production.apiKey

        #expect(apiKey == Secrets.supabasePublishableApiKey)
    }

    // MARK: - Display Name Tests

    @Test
    func displayName_isNotEmpty() {
        // ローカライズされた表示名が空でないことを確認
        // 実際の文字列は言語設定によって異なる
        #expect(!SupabaseEnvironment.local.displayName.isEmpty)
        #expect(!SupabaseEnvironment.production.displayName.isEmpty)
    }

    @Test
    func displayName_areDifferent() {
        // local と production で異なる表示名が返ることを確認
        #expect(SupabaseEnvironment.local.displayName != SupabaseEnvironment.production.displayName)
    }

    // MARK: - CaseIterable Tests

    @Test
    func allCases_containsBothEnvironments() {
        let allCases = SupabaseEnvironment.allCases

        #expect(allCases.count == 2)
        #expect(allCases.contains(.production))
        #expect(allCases.contains(.local))
    }

    // MARK: - Identifiable Tests

    @Test
    func id_returnsRawValue() {
        #expect(SupabaseEnvironment.local.id == "local")
        #expect(SupabaseEnvironment.production.id == "production")
    }
}
