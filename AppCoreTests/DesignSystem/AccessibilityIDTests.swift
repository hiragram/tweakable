import Foundation
import SwiftUI
import Testing
@testable import AppCore

@Suite
struct AccessibilityIDTests {

    // MARK: - Protocol Conformance Tests

    /// テスト用のダミーenum
    enum TestAccessibilityID: AccessibilityIDConvertible {
        case staticButton
        case dynamicItem(index: Int)

        var rawIdentifier: String {
            switch self {
            case .staticButton:
                return "test_button_static"
            case .dynamicItem(let index):
                return "test_item_\(index)"
            }
        }
    }

    @Test
    func accessibilityID_staticCase_returnsCorrectIdentifier() {
        let id = TestAccessibilityID.staticButton
        #expect(id.rawIdentifier == "test_button_static")
    }

    @Test
    func accessibilityID_dynamicCase_returnsCorrectIdentifier() {
        let id = TestAccessibilityID.dynamicItem(index: 3)
        #expect(id.rawIdentifier == "test_item_3")
    }

    @Test
    func accessibilityID_dynamicCase_differentIndices_returnDifferentIdentifiers() {
        let id1 = TestAccessibilityID.dynamicItem(index: 0)
        let id2 = TestAccessibilityID.dynamicItem(index: 5)
        #expect(id1.rawIdentifier != id2.rawIdentifier)
        #expect(id1.rawIdentifier == "test_item_0")
        #expect(id2.rawIdentifier == "test_item_5")
    }
}
