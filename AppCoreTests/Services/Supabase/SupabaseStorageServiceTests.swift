import Testing
import Foundation
@testable import AppCore

@Suite
struct SupabaseStorageServiceTests {

    // MARK: - Profile Tests

    @Test
    func saveProfile_createsNewProfile() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let userID = UUID()
        let profile = Profile(id: userID, displayName: "Test User")

        // Act
        let savedProfile = try await mockService.saveProfile(profile)

        // Assert
        #expect(savedProfile.id == userID)
        #expect(savedProfile.displayName == "Test User")
        #expect(savedProfile.createdAt != nil)
        #expect(savedProfile.updatedAt != nil)
        #expect(mockService.saveProfileCallCount == 1)
    }

    @Test
    func fetchProfile_returnsExistingProfile() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let userID = UUID()
        let profile = Profile(id: userID, displayName: "Existing User")
        _ = try await mockService.saveProfile(profile)

        // Act
        let fetchedProfile = try await mockService.fetchProfile(userID: userID)

        // Assert
        #expect(fetchedProfile?.displayName == "Existing User")
    }

    @Test
    func fetchProfile_returnsNilForNonExistentUser() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()

        // Act
        let fetchedProfile = try await mockService.fetchProfile(userID: UUID())

        // Assert
        #expect(fetchedProfile == nil)
    }

    // MARK: - Group Tests

    @Test
    func createGroup_createsGroupAndOwnerMembership() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let ownerID = UUID()
        let groupID = UUID()
        let group = SupabaseUserGroup(id: groupID, name: "Family", ownerID: ownerID)

        // Act
        let savedGroup = try await mockService.createGroup(group)

        // Assert
        #expect(savedGroup.id == groupID)
        #expect(savedGroup.name == "Family")
        #expect(savedGroup.ownerID == ownerID)

        // オーナーのメンバーシップも自動作成されていることを確認
        let userGroups = try await mockService.fetchGroupsForUser(userID: ownerID)
        #expect(userGroups.count == 1)
        #expect(userGroups.first?.id == groupID)
    }

    @Test
    func fetchGroup_returnsExistingGroup() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let group = SupabaseUserGroup(id: groupID, name: "Team", ownerID: UUID())
        _ = try await mockService.createGroup(group)

        // Act
        let fetchedGroup = try await mockService.fetchGroup(groupID: groupID)

        // Assert
        #expect(fetchedGroup?.name == "Team")
    }

    // MARK: - Membership Tests

    @Test
    func createMembership_createsPendingMembership() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let userID = UUID()
        let groupID = UUID()

        // Act
        let membership = try await mockService.createMembership(userID: userID, groupID: groupID)

        // Assert
        #expect(membership.userID == userID)
        #expect(membership.groupID == groupID)
        #expect(membership.status == .pending)
    }

    @Test
    func updateMembershipStatus_approvesRequest() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let ownerID = UUID()
        let newUserID = UUID()
        let groupID = UUID()

        // まずグループを作成
        let group = SupabaseUserGroup(id: groupID, name: "Test Group", ownerID: ownerID)
        _ = try await mockService.createGroup(group)

        // 新しいユーザーがpendingで参加リクエスト
        let membership = try await mockService.createMembership(userID: newUserID, groupID: groupID)

        // Act: 承認
        try await mockService.updateMembershipStatus(membershipID: membership.id, status: .approved)

        // Assert: 承認されたユーザーがグループを取得できる
        let userGroups = try await mockService.fetchGroupsForUser(userID: newUserID)
        #expect(userGroups.count == 1)
        #expect(userGroups.first?.id == groupID)
    }

    @Test
    func fetchPendingMemberships_returnsOnlyPending() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let group = SupabaseUserGroup(id: groupID, name: "Group", ownerID: UUID())
        _ = try await mockService.createGroup(group)

        let user1 = UUID()
        let user2 = UUID()
        let membership1 = try await mockService.createMembership(userID: user1, groupID: groupID)
        let membership2 = try await mockService.createMembership(userID: user2, groupID: groupID)

        // user1を承認
        try await mockService.updateMembershipStatus(membershipID: membership1.id, status: .approved)

        // Act
        let pendingMemberships = try await mockService.fetchPendingMemberships(groupID: groupID)

        // Assert
        #expect(pendingMemberships.count == 1)
        #expect(pendingMemberships.first?.userID == user2)
    }

    // MARK: - Schedule Entry Tests

    @Test
    func saveScheduleEntry_savesEntry() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let entry = SupabaseScheduleEntry(
            id: UUID(),
            userID: UUID(),
            groupID: UUID(),
            date: Date(),
            dropOffStatus: .ok,
            pickUpStatus: .ng
        )

        // Act
        let savedEntry = try await mockService.saveScheduleEntry(entry)

        // Assert
        #expect(savedEntry.dropOffStatus == .ok)
        #expect(savedEntry.pickUpStatus == .ng)
    }

    @Test
    func fetchScheduleEntries_returnsEntriesInDateRange() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 3日分のエントリを作成
        for dayOffset in 0..<3 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let entry = SupabaseScheduleEntry(
                id: UUID(),
                userID: UUID(),
                groupID: groupID,
                date: date
            )
            _ = try await mockService.saveScheduleEntry(entry)
        }

        // Act: 最初の2日分だけ取得
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let entries = try await mockService.fetchScheduleEntries(
            groupID: groupID,
            from: today,
            to: endDate
        )

        // Assert
        #expect(entries.count == 2)
    }

    // MARK: - Day Assignment Tests

    @Test
    func saveDayAssignment_savesAssignment() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let dropOffUserID = UUID()
        let pickUpUserID = UUID()
        let assignment = SupabaseDayAssignment(
            id: UUID(),
            groupID: UUID(),
            date: Date(),
            dropOffUserID: dropOffUserID,
            pickUpUserID: pickUpUserID
        )

        // Act
        let savedAssignment = try await mockService.saveDayAssignment(assignment)

        // Assert
        #expect(savedAssignment.dropOffUserID == dropOffUserID)
        #expect(savedAssignment.pickUpUserID == pickUpUserID)
    }

    // MARK: - Weather Location Tests

    @Test
    func saveWeatherLocation_savesLocation() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let location = SupabaseWeatherLocation(
            id: UUID(),
            groupID: UUID(),
            name: "Tokyo",
            latitude: 35.6762,
            longitude: 139.6503
        )

        // Act
        let savedLocation = try await mockService.saveWeatherLocation(location)

        // Assert
        #expect(savedLocation.name == "Tokyo")
        #expect(savedLocation.latitude == 35.6762)
    }

    @Test
    func deleteWeatherLocation_removesLocation() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let location = SupabaseWeatherLocation(
            id: UUID(),
            groupID: groupID,
            name: "Osaka",
            latitude: 34.6937,
            longitude: 135.5023
        )
        _ = try await mockService.saveWeatherLocation(location)

        // Act
        try await mockService.deleteWeatherLocation(location)

        // Assert
        let locations = try await mockService.fetchWeatherLocations(groupID: groupID)
        #expect(locations.isEmpty)
    }

    // MARK: - Invite Code Tests

    @Test
    func createInviteCode_generatesValidCode() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let createdBy = UUID()

        // Act
        let inviteCode = try await mockService.createInviteCode(groupID: groupID, createdBy: createdBy)

        // Assert
        #expect(inviteCode.code.count == 6)
        #expect(inviteCode.groupID == groupID)
        #expect(inviteCode.createdBy == createdBy)
        #expect(inviteCode.usedBy == nil)
        #expect(inviteCode.usedAt == nil)
        #expect(mockService.createInviteCodeCallCount == 1)
    }

    @Test
    func createInviteCode_generatesUppercaseAlphanumeric() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let createdBy = UUID()

        // Act
        let inviteCode = try await mockService.createInviteCode(groupID: groupID, createdBy: createdBy)

        // Assert - コードは英数大文字のみで構成される
        let validCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let codeCharacters = CharacterSet(charactersIn: inviteCode.code)
        #expect(validCharacters.isSuperset(of: codeCharacters))
    }

    @Test
    func fetchInviteCode_returnsUnusedCode() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let createdBy = UUID()
        let createdCode = try await mockService.createInviteCode(groupID: groupID, createdBy: createdBy)

        // Act
        let fetchedCode = try await mockService.fetchInviteCode(code: createdCode.code)

        // Assert
        #expect(fetchedCode?.id == createdCode.id)
        #expect(fetchedCode?.groupID == groupID)
    }

    @Test
    func fetchInviteCode_returnsNilForNonExistentCode() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()

        // Act
        let fetchedCode = try await mockService.fetchInviteCode(code: "ABCDEF")

        // Assert
        #expect(fetchedCode == nil)
    }

    @Test
    func fetchInviteCode_returnsNilForUsedCode() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let createdBy = UUID()
        let usedBy = UUID()
        let createdCode = try await mockService.createInviteCode(groupID: groupID, createdBy: createdBy)
        _ = try await mockService.useInviteCode(code: createdCode.code, usedBy: usedBy)

        // Act
        let fetchedCode = try await mockService.fetchInviteCode(code: createdCode.code)

        // Assert
        #expect(fetchedCode == nil)
    }

    @Test
    func useInviteCode_marksCodeAsUsed() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let createdBy = UUID()
        let usedBy = UUID()
        let createdCode = try await mockService.createInviteCode(groupID: groupID, createdBy: createdBy)

        // Act
        let usedCode = try await mockService.useInviteCode(code: createdCode.code, usedBy: usedBy)

        // Assert
        #expect(usedCode.usedBy == usedBy)
        #expect(usedCode.usedAt != nil)
        #expect(mockService.useInviteCodeCallCount == 1)
    }

    @Test
    func useInviteCode_throwsForAlreadyUsedCode() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let groupID = UUID()
        let createdBy = UUID()
        let usedBy1 = UUID()
        let usedBy2 = UUID()
        let createdCode = try await mockService.createInviteCode(groupID: groupID, createdBy: createdBy)
        _ = try await mockService.useInviteCode(code: createdCode.code, usedBy: usedBy1)

        // Act & Assert
        do {
            _ = try await mockService.useInviteCode(code: createdCode.code, usedBy: usedBy2)
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            // Expected
            #expect(true)
        }
    }

    // MARK: - FCM Token Tests

    @Test
    func saveFCMToken_updatesProfileFCMToken() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let userID = UUID()
        let profile = Profile(id: userID, displayName: "Test User")
        _ = try await mockService.saveProfile(profile)

        // Act
        try await mockService.saveFCMToken("new-fcm-token-123", userID: userID)

        // Assert
        let fetchedProfile = try await mockService.fetchProfile(userID: userID)
        #expect(fetchedProfile?.fcmToken == "new-fcm-token-123")
        #expect(mockService.saveFCMTokenCallCount == 1)
    }

    @Test
    func saveFCMToken_doesNotThrowForNonExistentProfile() async throws {
        // Arrange
        let mockService = MockSupabaseStorageService()
        let userID = UUID()

        // Act - profileが存在しない場合でもエラーにならないことを確認
        try await mockService.saveFCMToken("token", userID: userID)

        // Assert
        #expect(mockService.saveFCMTokenCallCount == 1)
    }
}
