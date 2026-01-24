import Foundation

/// AccessibilityIdentifier用のプロトコル
/// 各ViewのAccessibilityID enumが準拠する
public protocol AccessibilityIDConvertible: Sendable {
    /// accessibilityIdentifierとして使用する文字列を返す
    var rawIdentifier: String { get }
}
