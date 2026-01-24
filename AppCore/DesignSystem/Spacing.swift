import SwiftUI

// MARK: - Spacing Scale

struct SpacingScale {
    let xxs: CGFloat
    let xs: CGFloat
    let sm: CGFloat
    let md: CGFloat
    let lg: CGFloat
    let xl: CGFloat
    let xxl: CGFloat
    let xxxl: CGFloat
}

extension SpacingScale {
    static let `default` = SpacingScale(
        xxs: 4,
        xs: 8,
        sm: 12,
        md: 16,
        lg: 24,
        xl: 32,
        xxl: 48,
        xxxl: 64
    )
}

// MARK: - Corner Radius Scale

struct CornerRadiusScale {
    let xs: CGFloat
    let sm: CGFloat
    let md: CGFloat
    let lg: CGFloat
    let xl: CGFloat
    let full: CGFloat
}

extension CornerRadiusScale {
    /// Rounded corners for friendly/soft style
    static let `default` = CornerRadiusScale(
        xs: 8,
        sm: 12,
        md: 16,
        lg: 20,
        xl: 28,
        full: .infinity
    )
}

// MARK: - Shadow Scale

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct ShadowScale {
    let sm: ShadowStyle
    let md: ShadowStyle
    let lg: ShadowStyle
    /// 上向きの影（フローティング要素用）
    let floatingUp: ShadowStyle
}

extension ShadowScale {
    /// Soft shadows for friendly feel
    static let `default` = ShadowScale(
        sm: ShadowStyle(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2),
        md: ShadowStyle(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4),
        lg: ShadowStyle(color: Color.black.opacity(0.10), radius: 16, x: 0, y: 8),
        floatingUp: ShadowStyle(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -6)
    )
}

// MARK: - Layout Constants

struct LayoutConstants {
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let minTouchTarget: CGFloat
    let iconSizeSmall: CGFloat
    let iconSize: CGFloat
    let iconSizeLarge: CGFloat
}

extension LayoutConstants {
    static let `default` = LayoutConstants(
        horizontalPadding: 16,
        verticalPadding: 16,
        minTouchTarget: 44,
        iconSizeSmall: 16,
        iconSize: 24,
        iconSizeLarge: 32
    )
}

// MARK: - View Extensions

extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
