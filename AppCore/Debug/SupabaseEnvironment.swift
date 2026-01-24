//
//  SupabaseEnvironment.swift
//  AppCore
//
//  Created by Claude on 2026/01/14.
//

import Foundation

/// Supabase接続先環境
public enum SupabaseEnvironment: String, CaseIterable, Identifiable {
    case production
    case local

    public var id: String { rawValue }

    /// 環境の表示名
    public var displayName: String {
        switch self {
        case .production:
            return String(localized: "debug_environment_production", bundle: .app)
        case .local:
            return String(localized: "debug_environment_local", bundle: .app)
        }
    }

    /// 環境の説明
    public var description: String {
        switch self {
        case .production:
            return Secrets.supabaseProjectUrl
        case .local:
            return "http://localhost:\(Secrets.supabaseLocalPort)"
        }
    }

    /// Supabase URL
    public var url: String {
        switch self {
        case .production:
            return Secrets.supabaseProjectUrl
        case .local:
            return "http://localhost:\(Secrets.supabaseLocalPort)"
        }
    }

    /// Supabase API Key
    public var apiKey: String {
        switch self {
        case .production:
            return Secrets.supabasePublishableApiKey
        case .local:
            // Supabaseローカル開発用の固定キー（supabase startで使用されるデフォルト）
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
        }
    }

    // MARK: - UserDefaults Storage

    private static let userDefaultsKey = "supabaseEnvironment"

    /// 現在選択されている環境（UserDefaultsから読み込み、デフォルトはlocal）
    public static var current: SupabaseEnvironment {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
                  let environment = SupabaseEnvironment(rawValue: rawValue) else {
                return .local
            }
            return environment
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
        }
    }
}
