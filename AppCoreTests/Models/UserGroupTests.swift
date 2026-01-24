import Testing
import Foundation
@testable import AppCore

@Suite
struct UserGroupTests {

    // MARK: - Initialization Tests

    @Test
    func userGroup_init_setsName() {
        let userGroup = UserGroup(name: "山田家")
        #expect(userGroup.name == "山田家")
    }

    @Test
    func userGroup_init_generatesUniqueId() {
        let group1 = UserGroup(name: "山田家")
        let group2 = UserGroup(name: "山田家")
        #expect(group1.id != group2.id)
    }

    @Test
    func userGroup_init_canSetCustomId() {
        let customID = UUID()
        let userGroup = UserGroup(id: customID, name: "山田家")
        #expect(userGroup.id == customID)
    }

    // MARK: - Identifiable Tests

    @Test
    func userGroup_id_isUsedForIdentification() {
        let id = UUID()
        let userGroup = UserGroup(id: id, name: "山田家")
        #expect(userGroup.id == id)
    }

    // MARK: - Mutability Tests

    @Test
    func userGroup_name_isMutable() {
        var userGroup = UserGroup(name: "山田家")
        userGroup.name = "田中家"
        #expect(userGroup.name == "田中家")
    }
}
