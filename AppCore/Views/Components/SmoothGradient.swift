import SwiftUI

/// EaseInOutカーブに基づいたスムーズなグラデーション
///
/// 通常のLinearGradientと違い、始点と終点付近で変化が緩やかになる。
/// ナビゲーションバーへのフェードや、画像の上に重ねるオーバーレイに適している。
struct SmoothGradient: View {
    private let from: Color
    private let to: Color
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    /// - Parameters:
    ///   - from: 開始色
    ///   - to: 終了色
    ///   - startPoint: グラデーションの開始位置
    ///   - endPoint: グラデーションの終了位置
    init(
        from: Color,
        to: Color,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) {
        self.from = from
        self.to = to
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    var body: some View {
        LinearGradient(
            stops: easeInOutStops,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// EaseInOutカーブを近似したグラデーションstops
    ///
    /// fromが透明、toが不透明な色の場合、toの色をeaseInOutカーブに沿った
    /// opacityで配置することでスムーズな遷移を実現する
    private var easeInOutStops: [Gradient.Stop] {
        // 11点（10分割）でサンプリング
        // - 5点以下: カーブの変曲点でバンディングが目立つ
        // - 11点: 視覚的に滑らかで、計算コストも許容範囲
        // - 20点以上: 改善は微小で、メモリ使用量が増加
        (0...10).map { i in
            let t = Double(i) / 10.0
            let eased = easeInOut(t)
            return .init(color: to.opacity(eased), location: t)
        }
    }

    /// EaseInOut関数（cubic）
    private func easeInOut(_ t: Double) -> Double {
        if t < 0.5 {
            return 4 * t * t * t
        } else {
            return 1 - pow(-2 * t + 2, 3) / 2
        }
    }
}

// MARK: - Preview

#Preview("Smooth vs Linear") {
    VStack(spacing: 20) {
        Text("SmoothGradient (EaseInOut)")
            .font(.caption)
        SmoothGradient(
            from: .clear,
            to: .black,
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 100)

        Text("LinearGradient")
            .font(.caption)
        LinearGradient(
            colors: [.clear, .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 100)
    }
    .padding()
}
