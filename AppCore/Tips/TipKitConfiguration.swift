//
//  TipKitConfiguration.swift
//  AppCore
//

import TipKit

enum TipKitConfiguration {
    /// UIテスト中はTipを無効化するためのフラグ
    /// Launch Argumentsで `-disableTips` を渡すとTipが表示されなくなる
    private static var isTipsDisabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-disableTips")
    }

    static func configure() {
        // UIテスト中はTipを無効化
        guard !isTipsDisabled else {
            return
        }

        do {
            #if DEBUG
            // DEBUGビルドでは即時表示
            try Tips.configure([.displayFrequency(.immediate)])
            #else
            // 本番では1日1回まで
            try Tips.configure([.displayFrequency(.daily)])
            #endif
        } catch {
            // TipKitの設定エラーはアプリの動作に影響しないため無視
            print("TipKit configuration failed: \(error)")
        }
    }
}
