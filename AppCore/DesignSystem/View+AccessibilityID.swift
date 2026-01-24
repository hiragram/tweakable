import SwiftUI

public extension View {
    /// 型安全なaccessibilityIdentifierを設定
    /// - Parameter id: AccessibilityIDConvertibleに準拠したenum
    /// - Returns: accessibilityIdentifierが設定されたView
    func accessibilityIdentifier<ID: AccessibilityIDConvertible>(_ id: ID) -> some View {
        self.accessibilityIdentifier(id.rawIdentifier)
    }
}
