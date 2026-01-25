import AppCore
import XCTest

// MARK: - XCUIElementQuery Extension

extension XCUIElementQuery {
    /// AccessibilityIDを使って要素を取得
    subscript<ID: AccessibilityIDConvertible>(_ id: ID) -> XCUIElement {
        self[id.rawIdentifier]
    }
}

// MARK: - XCUIApplication Extension

extension XCUIApplication {
    /// AccessibilityIDを使ってボタンを取得
    func button<ID: AccessibilityIDConvertible>(_ id: ID) -> XCUIElement {
        buttons[id.rawIdentifier]
    }

    /// AccessibilityIDを使ってテキストフィールドを取得
    func textField<ID: AccessibilityIDConvertible>(_ id: ID) -> XCUIElement {
        textFields[id.rawIdentifier]
    }

    /// AccessibilityIDを使ってメニューアイテムを取得
    func menuItem<ID: AccessibilityIDConvertible>(_ id: ID) -> XCUIElement {
        menuItems[id.rawIdentifier]
    }

    /// AccessibilityIDを使って任意の要素を取得
    func element<ID: AccessibilityIDConvertible>(_ id: ID) -> XCUIElement {
        descendants(matching: .any)[id.rawIdentifier]
    }
}
