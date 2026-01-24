import Foundation
@testable import AppCore

/// テスト用のSupabaseストレージサービスモック
final class MockSupabaseStorageService: SupabaseStorageServiceProtocol, @unchecked Sendable {
    // MARK: - Mock Data Storage

    var profiles: [UUID: Profile] = [:]
    var groups: [UUID: SupabaseUserGroup] = [:]
    var memberships: [UUID: SupabaseGroupMembership] = [:]
    var scheduleEntries: [UUID: SupabaseScheduleEntry] = [:]
    var dayAssignments: [UUID: SupabaseDayAssignment] = [:]
    var weatherLocations: [UUID: SupabaseWeatherLocation] = [:]
    var inviteCodes: [String: SupabaseInviteCode] = [:]

    // MARK: - Call Tracking

    var saveProfileCallCount = 0
    var fetchProfileCallCount = 0
    var createGroupCallCount = 0
    var fetchGroupCallCount = 0
    var fetchGroupsForUserCallCount = 0
    var createMembershipCallCount = 0
    var updateMembershipStatusCallCount = 0
    var fetchPendingMembershipsCallCount = 0
    var saveScheduleEntryCallCount = 0
    var saveScheduleEntriesCallCount = 0
    var fetchScheduleEntriesCallCount = 0
    var saveDayAssignmentCallCount = 0
    var fetchDayAssignmentsCallCount = 0
    var saveWeatherLocationCallCount = 0
    var fetchWeatherLocationsCallCount = 0
    var deleteWeatherLocationCallCount = 0
    var createInviteCodeCallCount = 0
    var fetchInviteCodeCallCount = 0
    var useInviteCodeCallCount = 0

    // MARK: - Error Simulation

    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: 1)

    // MARK: - Profile Operations

    func saveProfile(_ profile: Profile) async throws -> Profile {
        saveProfileCallCount += 1
        if shouldThrowError { throw errorToThrow }
        var savedProfile = profile
        savedProfile = Profile(
            id: profile.id,
            displayName: profile.displayName,
            fcmToken: profile.fcmToken,
            createdAt: profile.createdAt ?? Date(),
            updatedAt: Date()
        )
        profiles[profile.id] = savedProfile
        return savedProfile
    }

    func fetchProfile(userID: UUID) async throws -> Profile? {
        fetchProfileCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return profiles[userID]
    }

    var saveFCMTokenCallCount = 0

    func saveFCMToken(_ token: String, userID: UUID) async throws {
        saveFCMTokenCallCount += 1
        if shouldThrowError { throw errorToThrow }

        // 既存のプロフィールがあればfcmTokenを更新
        if var profile = profiles[userID] {
            profile = Profile(
                id: profile.id,
                displayName: profile.displayName,
                fcmToken: token,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profiles[userID] = profile
        }
    }

    // MARK: - Group Operations

    func createGroup(_ group: SupabaseUserGroup) async throws -> SupabaseUserGroup {
        createGroupCallCount += 1
        if shouldThrowError { throw errorToThrow }
        var savedGroup = SupabaseUserGroup(
            id: group.id,
            name: group.name,
            ownerID: group.ownerID,
            createdAt: Date(),
            updatedAt: Date()
        )
        groups[group.id] = savedGroup

        // 自動的にオーナーのメンバーシップも作成（approved状態で）
        let membership = SupabaseGroupMembership(
            id: UUID(),
            userID: group.ownerID,
            groupID: group.id,
            status: .approved,
            createdAt: Date(),
            updatedAt: Date()
        )
        memberships[membership.id] = membership

        return savedGroup
    }

    func fetchGroup(groupID: UUID) async throws -> SupabaseUserGroup? {
        fetchGroupCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return groups[groupID]
    }

    func fetchGroupsForUser(userID: UUID) async throws -> [SupabaseUserGroup] {
        fetchGroupsForUserCallCount += 1
        if shouldThrowError { throw errorToThrow }

        // 承認済みメンバーシップからグループIDを取得
        let approvedGroupIDs = memberships.values
            .filter { $0.userID == userID && $0.status == .approved }
            .map { $0.groupID }

        return groups.values.filter { approvedGroupIDs.contains($0.id) }
    }

    // MARK: - Membership Operations

    func createMembership(userID: UUID, groupID: UUID) async throws -> SupabaseGroupMembership {
        createMembershipCallCount += 1
        if shouldThrowError { throw errorToThrow }

        let membership = SupabaseGroupMembership(
            id: UUID(),
            userID: userID,
            groupID: groupID,
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        memberships[membership.id] = membership
        return membership
    }

    func updateMembershipStatus(membershipID: UUID, status: SupabaseMembershipStatus) async throws {
        updateMembershipStatusCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var membership = memberships[membershipID] else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Membership not found"])
        }

        membership = SupabaseGroupMembership(
            id: membership.id,
            userID: membership.userID,
            groupID: membership.groupID,
            status: status,
            createdAt: membership.createdAt,
            updatedAt: Date()
        )
        memberships[membershipID] = membership
    }

    func fetchPendingMemberships(groupID: UUID) async throws -> [SupabaseGroupMembership] {
        fetchPendingMembershipsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        return memberships.values.filter { $0.groupID == groupID && $0.status == .pending }
    }

    var fetchGroupMembershipsCallCount = 0

    func fetchGroupMemberships(groupID: UUID) async throws -> [SupabaseGroupMembership] {
        fetchGroupMembershipsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        return Array(memberships.values.filter { $0.groupID == groupID })
    }

    // MARK: - Schedule Entry Operations

    func saveScheduleEntry(_ entry: SupabaseScheduleEntry) async throws -> SupabaseScheduleEntry {
        saveScheduleEntryCallCount += 1
        if shouldThrowError { throw errorToThrow }

        var savedEntry = SupabaseScheduleEntry(
            id: entry.id,
            userID: entry.userID,
            groupID: entry.groupID,
            date: entry.date,
            dropOffStatus: entry.dropOffStatus,
            pickUpStatus: entry.pickUpStatus,
            note: entry.note,
            createdAt: entry.createdAt ?? Date(),
            updatedAt: Date()
        )
        scheduleEntries[entry.id] = savedEntry
        return savedEntry
    }

    func saveScheduleEntries(_ entries: [SupabaseScheduleEntry]) async throws -> [SupabaseScheduleEntry] {
        saveScheduleEntriesCallCount += 1
        if shouldThrowError { throw errorToThrow }

        var savedEntries: [SupabaseScheduleEntry] = []
        for entry in entries {
            let saved = try await saveScheduleEntry(entry)
            savedEntries.append(saved)
        }
        return savedEntries
    }

    func fetchScheduleEntries(groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseScheduleEntry] {
        fetchScheduleEntriesCallCount += 1
        if shouldThrowError { throw errorToThrow }

        return scheduleEntries.values.filter { entry in
            entry.groupID == groupID &&
            entry.date >= startDate &&
            entry.date <= endDate
        }
    }

    var fetchScheduleEntriesForUserCallCount = 0

    func fetchScheduleEntries(userID: UUID, groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseScheduleEntry] {
        fetchScheduleEntriesForUserCallCount += 1
        if shouldThrowError { throw errorToThrow }

        return scheduleEntries.values.filter { entry in
            entry.userID == userID &&
            entry.groupID == groupID &&
            entry.date >= startDate &&
            entry.date <= endDate
        }
    }

    // MARK: - Day Assignment Operations

    func saveDayAssignment(_ assignment: SupabaseDayAssignment) async throws -> SupabaseDayAssignment {
        saveDayAssignmentCallCount += 1
        if shouldThrowError { throw errorToThrow }

        var savedAssignment = SupabaseDayAssignment(
            id: assignment.id,
            groupID: assignment.groupID,
            date: assignment.date,
            dropOffUserID: assignment.dropOffUserID,
            pickUpUserID: assignment.pickUpUserID,
            createdAt: assignment.createdAt ?? Date(),
            updatedAt: Date()
        )
        dayAssignments[assignment.id] = savedAssignment
        return savedAssignment
    }

    var saveDayAssignmentsCallCount = 0

    func saveDayAssignments(_ assignments: [SupabaseDayAssignment]) async throws -> [SupabaseDayAssignment] {
        saveDayAssignmentsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        var savedAssignments: [SupabaseDayAssignment] = []
        for assignment in assignments {
            let saved = try await saveDayAssignment(assignment)
            savedAssignments.append(saved)
        }
        return savedAssignments
    }

    func fetchDayAssignments(groupID: UUID, from startDate: Date, to endDate: Date) async throws -> [SupabaseDayAssignment] {
        fetchDayAssignmentsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        return dayAssignments.values.filter { assignment in
            assignment.groupID == groupID &&
            assignment.date >= startDate &&
            assignment.date <= endDate
        }
    }

    // MARK: - Weather Location Operations

    func saveWeatherLocation(_ location: SupabaseWeatherLocation) async throws -> SupabaseWeatherLocation {
        saveWeatherLocationCallCount += 1
        if shouldThrowError { throw errorToThrow }

        var savedLocation = SupabaseWeatherLocation(
            id: location.id,
            groupID: location.groupID,
            name: location.name,
            latitude: location.latitude,
            longitude: location.longitude,
            createdAt: location.createdAt ?? Date(),
            updatedAt: Date()
        )
        weatherLocations[location.id] = savedLocation
        return savedLocation
    }

    func fetchWeatherLocations(groupID: UUID) async throws -> [SupabaseWeatherLocation] {
        fetchWeatherLocationsCallCount += 1
        if shouldThrowError { throw errorToThrow }

        return weatherLocations.values.filter { $0.groupID == groupID }
    }

    func deleteWeatherLocation(_ location: SupabaseWeatherLocation) async throws {
        deleteWeatherLocationCallCount += 1
        if shouldThrowError { throw errorToThrow }

        weatherLocations.removeValue(forKey: location.id)
    }

    var deleteWeatherLocationByIDCallCount = 0

    func deleteWeatherLocation(locationID: UUID) async throws {
        deleteWeatherLocationByIDCallCount += 1
        if shouldThrowError { throw errorToThrow }

        weatherLocations.removeValue(forKey: locationID)
    }

    // MARK: - Invite Code Operations

    func createInviteCode(groupID: UUID, createdBy: UUID) async throws -> SupabaseInviteCode {
        createInviteCodeCallCount += 1
        if shouldThrowError { throw errorToThrow }

        // 6桁英数大文字コードを生成
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0..<6).map { _ in characters.randomElement()! })

        let inviteCode = SupabaseInviteCode(
            id: UUID(),
            code: code,
            groupID: groupID,
            createdBy: createdBy,
            createdAt: Date()
        )
        inviteCodes[code] = inviteCode
        return inviteCode
    }

    func fetchInviteCode(code: String) async throws -> SupabaseInviteCode? {
        fetchInviteCodeCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard let inviteCode = inviteCodes[code], inviteCode.usedAt == nil else {
            return nil
        }
        return inviteCode
    }

    func useInviteCode(code: String, usedBy: UUID) async throws -> SupabaseInviteCode {
        useInviteCodeCallCount += 1
        if shouldThrowError { throw errorToThrow }

        guard var inviteCode = inviteCodes[code], inviteCode.usedAt == nil else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invite code not found or already used"])
        }

        inviteCode = SupabaseInviteCode(
            id: inviteCode.id,
            code: inviteCode.code,
            groupID: inviteCode.groupID,
            createdBy: inviteCode.createdBy,
            usedBy: usedBy,
            usedAt: Date(),
            createdAt: inviteCode.createdAt
        )
        inviteCodes[code] = inviteCode
        return inviteCode
    }

    var addMemberApprovedCallCount = 0

    func addMemberApproved(userID: UUID, groupID: UUID) async throws -> SupabaseGroupMembership {
        addMemberApprovedCallCount += 1
        if shouldThrowError { throw errorToThrow }

        let membership = SupabaseGroupMembership(
            id: UUID(),
            userID: userID,
            groupID: groupID,
            status: .approved,
            createdAt: Date(),
            updatedAt: Date()
        )
        memberships[membership.id] = membership
        return membership
    }
}
