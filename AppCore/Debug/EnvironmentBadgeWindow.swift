//
//  EnvironmentBadgeWindow.swift
//  AppCore
//
//  Created by Claude on 2026/01/14.
//

import SwiftUI
import UIKit

/// タッチイベントを透過するUIWindow
/// バッジ以外の領域へのタッチは下のWindowに伝搬する
final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        // rootViewControllerのviewへのタッチは透過させる
        // バッジ自体へのタッチも透過させる（タップで何かする必要がないので）
        return nil
    }
}

/// 環境バッジを表示するためのWindow管理クラス
@MainActor
public final class EnvironmentBadgeWindowManager {
    private var window: PassthroughWindow?

    public static let shared = EnvironmentBadgeWindowManager()

    private init() {}

    /// 環境バッジWindowを表示する
    /// - Parameter windowScene: 表示対象のWindowScene
    public func show(in windowScene: UIWindowScene) {
        guard window == nil else { return }

        let window = PassthroughWindow(windowScene: windowScene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear

        let hostingController = UIHostingController(
            rootView: EnvironmentBadgeContainerView()
        )
        hostingController.view.backgroundColor = .clear

        window.rootViewController = hostingController
        window.isHidden = false

        self.window = window
    }

    /// 環境バッジWindowを非表示にする
    public func hide() {
        window?.isHidden = true
        window = nil
    }
}

/// 環境バッジを画面下部中央に配置するコンテナ
private struct EnvironmentBadgeContainerView: View {
    var body: some View {
        VStack {
            Spacer()
            EnvironmentBadgeView(environment: SupabaseEnvironment.current)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }
}
