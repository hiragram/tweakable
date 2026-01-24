import Testing
import Foundation
@testable import AppCore

@Suite
struct UserTests {

    // MARK: - Test Constants

    private static let testICloudUserID = "_test-icloud-user-id"

    // MARK: - Initialization Tests

    @Test
    func user_init_setsDisplayName() {
        let user = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        #expect(user.displayName == "パパ")
    }

    @Test
    func user_init_setsICloudUserID() {
        let user = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        #expect(user.iCloudUserID == Self.testICloudUserID)
    }

    @Test
    func user_init_generatesUniqueId() {
        let user1 = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        let user2 = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        #expect(user1.id != user2.id)
    }

    @Test
    func user_init_canSetCustomId() {
        let customID = UUID()
        let user = User(id: customID, iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        #expect(user.id == customID)
    }

    // MARK: - Identifiable Tests

    @Test
    func user_id_isUsedForIdentification() {
        let id = UUID()
        let user = User(id: id, iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        #expect(user.id == id)
    }

    // MARK: - Mutability Tests

    @Test
    func user_displayName_isMutable() {
        var user = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        user.displayName = "ママ"
        #expect(user.displayName == "ママ")
    }
}
