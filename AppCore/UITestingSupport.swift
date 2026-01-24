//
//  UITestingSupport.swift
//  AppCore
//
//  UIテスト用のLaunch Arguments解析

import Foundation

/// UIテスト用のLaunch Arguments
public enum UITestingLaunchArgument: String, CaseIterable {
    /// 認証状態をリセット（未ログイン状態を強制）
    case resetAuth = "--uitesting-reset-auth"
}

/// UIテスト用のサポートユーティリティ
public struct UITestingSupport {
    /// UIテストモードかどうか（いずれかのUIテスト用引数が含まれている場合）
    public static var isUITesting: Bool {
        isUITesting(arguments: ProcessInfo.processInfo.arguments)
    }

    /// 認証状態をリセットすべきかどうか
    public static var shouldResetAuth: Bool {
        shouldResetAuth(arguments: ProcessInfo.processInfo.arguments)
    }

    // MARK: - Testable Methods

    /// UIテストモードかどうか（テスト用：引数を外部から注入可能）
    public static func isUITesting(arguments: [String]) -> Bool {
        UITestingLaunchArgument.allCases.contains { argument in
            arguments.contains(argument.rawValue)
        }
    }

    /// 認証状態をリセットすべきかどうか（テスト用：引数を外部から注入可能）
    public static func shouldResetAuth(arguments: [String]) -> Bool {
        arguments.contains(UITestingLaunchArgument.resetAuth.rawValue)
    }
}
