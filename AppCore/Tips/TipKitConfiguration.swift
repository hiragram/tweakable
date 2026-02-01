//
//  TipKitConfiguration.swift
//  AppCore
//

import TipKit

enum TipKitConfiguration {
    static func configure() {
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
