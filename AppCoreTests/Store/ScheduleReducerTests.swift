import Testing
import Foundation
@testable import AppCore

@Suite
struct ScheduleReducerTests {

    // MARK: - Test Constants

    private static let testICloudUserID = "_test-icloud-user-id"

    // MARK: - Test Helpers

    private func createStateWithUserAndGroup() -> ScheduleState {
        var state = ScheduleState()
        state.currentUser = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        state.currentGroup = UserGroup(name: "テスト家族")
        return state
    }

    // MARK: - User Actions Tests

    @Test
    func reduce_userSetupCompleted_setsCurrentUser() {
        var state = ScheduleState()
        let user = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")

        ScheduleReducer.reduce(state: &state, action: .userSetupCompleted(user))

        #expect(state.currentUser?.displayName == "パパ")
        #expect(state.currentUser?.id == user.id)
    }

    @Test
    func reduce_currentUserLoaded_setsUser() {
        var state = ScheduleState()
        let user = User(iCloudUserID: Self.testICloudUserID, displayName: "ママ")

        ScheduleReducer.reduce(state: &state, action: .currentUserLoaded(user))

        #expect(state.currentUser?.displayName == "ママ")
    }

    @Test
    func reduce_currentUserLoaded_nil_clearsUser() {
        var state = ScheduleState()
        state.currentUser = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")

        ScheduleReducer.reduce(state: &state, action: .currentUserLoaded(nil))

        #expect(state.currentUser == nil)
    }

    // MARK: - Schedule Actions Tests

    @Test
    func reduce_initializeWeekSchedule_createsSevenEntries() {
        var state = createStateWithUserAndGroup()
        let user = state.currentUser!
        let group = state.currentGroup!

        let weekStart = Calendar.current.startOfDay(for: Date())

        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: weekStart))

        #expect(state.weekEntries.count == 7)
        #expect(state.weekStartDate == weekStart)
        #expect(state.weekEntries.allSatisfy { $0.userID == user.id })
        #expect(state.weekEntries.allSatisfy { $0.userGroupID == group.id })
        #expect(state.weekEntries.allSatisfy { $0.dropOffStatus == .notSet })
        #expect(state.weekEntries.allSatisfy { $0.pickUpStatus == .notSet })
    }

    @Test
    func reduce_initializeWeekSchedule_withoutUser_doesNothing() {
        var state = ScheduleState()
        // No currentUser set

        let weekStart = Date()

        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: weekStart))

        #expect(state.weekEntries.isEmpty)
    }

    @Test
    func reduce_initializeWeekSchedule_withoutGroup_doesNothing() {
        var state = ScheduleState()
        state.currentUser = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        // No currentGroup set

        let weekStart = Date()

        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: weekStart))

        #expect(state.weekEntries.isEmpty)
    }

    @Test
    func reduce_loadWeekSchedule_setsLoadingAndWeekStart() {
        var state = ScheduleState()
        let weekStart = Date()

        ScheduleReducer.reduce(state: &state, action: .loadWeekSchedule(weekStartDate: weekStart))

        #expect(state.isLoading == true)
        #expect(state.weekStartDate == weekStart)
    }

    @Test
    func reduce_weekScheduleLoaded_mergesEntries() {
        var state = createStateWithUserAndGroup()
        let user = state.currentUser!
        let group = state.currentGroup!
        let weekStart = Calendar.current.startOfDay(for: Date())
        state.weekStartDate = weekStart
        state.isLoading = true

        let existingEntry = DayScheduleEntry(
            date: weekStart,
            userID: user.id,
            userGroupID: group.id,
            dropOffStatus: .ok,
            pickUpStatus: .ng
        )

        ScheduleReducer.reduce(state: &state, action: .weekScheduleLoaded([existingEntry]))

        #expect(state.isLoading == false)
        #expect(state.weekEntries.count == 7)
        #expect(state.weekEntries.first?.dropOffStatus == .ok)
        #expect(state.weekEntries.first?.pickUpStatus == .ng)
    }

    @Test
    func reduce_weekScheduleLoaded_ignoresEntriesFromDifferentUser() {
        var state = createStateWithUserAndGroup()
        let currentUser = state.currentUser!
        let group = state.currentGroup!
        let weekStart = Calendar.current.startOfDay(for: Date())
        state.weekStartDate = weekStart

        // 異なるユーザーのエントリを作成
        let otherUserID = UUID()
        let otherUserEntry = DayScheduleEntry(
            date: weekStart,
            userID: otherUserID,  // 現在のユーザーとは異なるID
            userGroupID: group.id,
            dropOffStatus: .ok,
            pickUpStatus: .ng
        )

        ScheduleReducer.reduce(state: &state, action: .weekScheduleLoaded([otherUserEntry]))

        // 異なるユーザーのエントリは無視され、現在のユーザー用に新しいエントリが作成される
        #expect(state.weekEntries.count == 7)
        #expect(state.weekEntries.first?.userID == currentUser.id)
        #expect(state.weekEntries.first?.dropOffStatus == .notSet)  // 他ユーザーの値(.ok)ではない
        #expect(state.weekEntries.first?.pickUpStatus == .notSet)   // 他ユーザーの値(.ng)ではない
    }

    @Test
    func reduce_weekScheduleLoaded_usesCurrentUserEntryWhenBothExist() {
        var state = createStateWithUserAndGroup()
        let currentUser = state.currentUser!
        let group = state.currentGroup!
        let weekStart = Calendar.current.startOfDay(for: Date())
        state.weekStartDate = weekStart

        // 異なるユーザーのエントリ
        let otherUserID = UUID()
        let otherUserEntry = DayScheduleEntry(
            date: weekStart,
            userID: otherUserID,
            userGroupID: group.id,
            dropOffStatus: .ng,
            pickUpStatus: .ng
        )

        // 現在のユーザーのエントリ
        let currentUserEntry = DayScheduleEntry(
            date: weekStart,
            userID: currentUser.id,
            userGroupID: group.id,
            dropOffStatus: .ok,
            pickUpStatus: .ok
        )

        // 両方のエントリを渡す（他ユーザーのエントリが先）
        ScheduleReducer.reduce(state: &state, action: .weekScheduleLoaded([otherUserEntry, currentUserEntry]))

        // 現在のユーザーのエントリが使用される
        #expect(state.weekEntries.count == 7)
        #expect(state.weekEntries.first?.userID == currentUser.id)
        #expect(state.weekEntries.first?.dropOffStatus == .ok)
        #expect(state.weekEntries.first?.pickUpStatus == .ok)
    }

    @Test
    func reduce_updateEntry_updatesDropOffStatus() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        ScheduleReducer.reduce(state: &state, action: .updateEntry(index: 0, dropOff: .ok, pickUp: nil))

        #expect(state.weekEntries[0].dropOffStatus == .ok)
        #expect(state.weekEntries[0].pickUpStatus == .notSet)
    }

    @Test
    func reduce_updateEntry_updatesPickUpStatus() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        ScheduleReducer.reduce(state: &state, action: .updateEntry(index: 0, dropOff: nil, pickUp: .ng))

        #expect(state.weekEntries[0].dropOffStatus == .notSet)
        #expect(state.weekEntries[0].pickUpStatus == .ng)
    }

    @Test
    func reduce_updateEntry_updatesBothStatuses() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        ScheduleReducer.reduce(state: &state, action: .updateEntry(index: 2, dropOff: .ng, pickUp: .ok))

        #expect(state.weekEntries[2].dropOffStatus == .ng)
        #expect(state.weekEntries[2].pickUpStatus == .ok)
    }

    @Test
    func reduce_updateEntry_invalidIndex_doesNothing() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        let entriesBefore = state.weekEntries

        ScheduleReducer.reduce(state: &state, action: .updateEntry(index: 100, dropOff: .ok, pickUp: .ok))

        #expect(state.weekEntries == entriesBefore)
    }

    @Test
    func reduce_submitSchedule_setsSaving() {
        var state = ScheduleState()

        ScheduleReducer.reduce(state: &state, action: .submitSchedule)

        #expect(state.isSaving == true)
    }

    @Test
    func reduce_submitCompleted_updatesEntriesAndClearsSaving() {
        var state = ScheduleState()
        state.isSaving = true

        let user = User(iCloudUserID: Self.testICloudUserID, displayName: "パパ")
        let group = UserGroup(name: "テスト家族")
        let savedEntries = (0..<7).map { index in
            DayScheduleEntry(
                date: Calendar.current.date(byAdding: .day, value: index, to: Date())!,
                userID: user.id,
                userGroupID: group.id,
                dropOffStatus: .ok,
                pickUpStatus: .ok
            )
        }

        ScheduleReducer.reduce(state: &state, action: .submitCompleted(savedEntries))

        #expect(state.isSaving == false)
        #expect(state.weekEntries.count == 7)
        #expect(state.weekEntries.allSatisfy { $0.dropOffStatus == .ok })
    }

    // MARK: - Loading Actions Tests

    @Test
    func reduce_setLoading_true_setsIsLoading() {
        var state = ScheduleState()

        ScheduleReducer.reduce(state: &state, action: .setLoading(true))

        #expect(state.isLoading == true)
    }

    @Test
    func reduce_setLoading_false_clearsIsLoading() {
        var state = ScheduleState()
        state.isLoading = true

        ScheduleReducer.reduce(state: &state, action: .setLoading(false))

        #expect(state.isLoading == false)
    }

    @Test
    func reduce_setSaving_true_setsIsSaving() {
        var state = ScheduleState()

        ScheduleReducer.reduce(state: &state, action: .setSaving(true))

        #expect(state.isSaving == true)
    }

    @Test
    func reduce_setSaving_false_clearsIsSaving() {
        var state = ScheduleState()
        state.isSaving = true

        ScheduleReducer.reduce(state: &state, action: .setSaving(false))

        #expect(state.isSaving == false)
    }

    // MARK: - Error Actions Tests

    @Test
    func reduce_errorOccurred_setsErrorMessage() {
        var state = ScheduleState()
        state.isLoading = true
        state.isSaving = true

        ScheduleReducer.reduce(state: &state, action: .errorOccurred("テストエラー"))

        #expect(state.errorMessage == "テストエラー")
        #expect(state.isLoading == false)
        #expect(state.isSaving == false)
    }

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = ScheduleState()
        state.errorMessage = "既存のエラー"

        ScheduleReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }

    // MARK: - UI Actions Tests

    @Test
    func reduce_showSuccessToast_setsFlag() {
        var state = ScheduleState()

        ScheduleReducer.reduce(state: &state, action: .showSuccessToast)

        #expect(state.showSuccessToast == true)
    }

    @Test
    func reduce_hideSuccessToast_clearsFlag() {
        var state = ScheduleState()
        state.showSuccessToast = true

        ScheduleReducer.reduce(state: &state, action: .hideSuccessToast)

        #expect(state.showSuccessToast == false)
    }

    // MARK: - Computed Properties Tests

    @Test
    func state_isAllFilled_returnsTrueWhenAllFilled() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        for i in 0..<7 {
            ScheduleReducer.reduce(state: &state, action: .updateEntry(index: i, dropOff: .ok, pickUp: .ng))
        }

        #expect(state.isAllFilled == true)
    }

    @Test
    func state_isAllFilled_returnsFalseWhenNotAllFilled() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        // Only fill first entry
        ScheduleReducer.reduce(state: &state, action: .updateEntry(index: 0, dropOff: .ok, pickUp: .ng))

        #expect(state.isAllFilled == false)
    }

    @Test
    func state_remainingCount_countsUnfilledEntries() {
        var state = createStateWithUserAndGroup()
        ScheduleReducer.reduce(state: &state, action: .initializeWeekSchedule(weekStartDate: Date()))

        // All entries are notSet, so 7 days * 2 = 14
        #expect(state.remainingCount == 14)

        // Fill one entry completely
        ScheduleReducer.reduce(state: &state, action: .updateEntry(index: 0, dropOff: .ok, pickUp: .ng))
        #expect(state.remainingCount == 12)
    }

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = ScheduleState()

        #expect(state.currentUser == nil)
        #expect(state.weekEntries.isEmpty)
        #expect(state.isLoading == false)
        #expect(state.isSaving == false)
        #expect(state.errorMessage == nil)
        #expect(state.isEditable == true)
        #expect(state.showSuccessToast == false)
        #expect(state.isCreatingGroup == false)
    }

    // MARK: - Group Creation Actions Tests

    @Test
    func reduce_startCreatingGroup_setsIsCreatingGroup() {
        var state = ScheduleState()

        ScheduleReducer.reduce(state: &state, action: .startCreatingGroup)

        #expect(state.isCreatingGroup == true)
    }

    @Test
    func reduce_groupCreated_setsGroupAndClearsCreating() {
        var state = ScheduleState()
        state.isCreatingGroup = true
        let group = UserGroup(name: "山田家")

        ScheduleReducer.reduce(state: &state, action: .groupCreated(group))

        #expect(state.currentGroup?.name == "山田家")
        #expect(state.isCreatingGroup == false)
    }

    @Test
    func reduce_groupCreationFailed_clearsCreatingAndSetsError() {
        var state = ScheduleState()
        state.isCreatingGroup = true

        ScheduleReducer.reduce(state: &state, action: .groupCreationFailed("作成に失敗しました"))

        #expect(state.isCreatingGroup == false)
        #expect(state.errorMessage == "作成に失敗しました")
    }

    // MARK: - Enabled Weekdays Tests

    @Test
    func reduce_updateEnabledWeekday_enablesWeekday() {
        var state = createStateWithUserAndGroup()
        // 初期状態: 土曜日(7)はOFF
        #expect(state.currentGroup?.enabledWeekdays[7] == false)

        ScheduleReducer.reduce(state: &state, action: .updateEnabledWeekday(weekday: 7, enabled: true))

        #expect(state.currentGroup?.enabledWeekdays[7] == true)
    }

    @Test
    func reduce_updateEnabledWeekday_disablesWeekday() {
        var state = createStateWithUserAndGroup()
        // 初期状態: 月曜日(2)はON
        #expect(state.currentGroup?.enabledWeekdays[2] == true)

        ScheduleReducer.reduce(state: &state, action: .updateEnabledWeekday(weekday: 2, enabled: false))

        #expect(state.currentGroup?.enabledWeekdays[2] == false)
    }

    @Test
    func reduce_updateEnabledWeekday_withoutGroup_doesNothing() {
        var state = ScheduleState()
        // No currentGroup set

        ScheduleReducer.reduce(state: &state, action: .updateEnabledWeekday(weekday: 2, enabled: false))

        #expect(state.currentGroup == nil)
    }

    @Test
    func userGroup_defaultEnabledWeekdays_hasWeekdaysOnly() {
        let group = UserGroup(name: "テスト家族")

        // 月〜金はON
        #expect(group.enabledWeekdays[2] == true)  // 月
        #expect(group.enabledWeekdays[3] == true)  // 火
        #expect(group.enabledWeekdays[4] == true)  // 水
        #expect(group.enabledWeekdays[5] == true)  // 木
        #expect(group.enabledWeekdays[6] == true)  // 金

        // 土日はOFF
        #expect(group.enabledWeekdays[7] == false) // 土
        #expect(group.enabledWeekdays[1] == false) // 日
    }

    // MARK: - Multiple Groups Tests

    @Test
    func state_groups_startsEmpty() {
        let state = ScheduleState()
        #expect(state.groups.isEmpty)
    }

    @Test
    func state_groupOwnership_startsEmpty() {
        let state = ScheduleState()
        #expect(state.groupOwnership.isEmpty)
    }

    @Test
    func reduce_groupsLoaded_setsGroups() {
        var state = ScheduleState()
        let group1 = UserGroup(name: "山田家")
        let group2 = UserGroup(name: "仕事チーム")

        ScheduleReducer.reduce(state: &state, action: .groupsLoaded([group1, group2]))

        #expect(state.groups.count == 2)
        #expect(state.groups[0].name == "山田家")
        #expect(state.groups[1].name == "仕事チーム")
    }

    @Test
    func reduce_selectGroup_setsCurrentGroup() {
        var state = ScheduleState()
        state.currentUser = User(iCloudUserID: Self.testICloudUserID, displayName: "テスト")
        let group1 = UserGroup(name: "山田家")
        let group2 = UserGroup(name: "仕事チーム")
        state.groups = [group1, group2]

        ScheduleReducer.reduce(state: &state, action: .selectGroup(group2.id))

        #expect(state.currentGroup?.id == group2.id)
        #expect(state.currentGroup?.name == "仕事チーム")
    }

    @Test
    func reduce_selectGroup_invalidID_doesNothing() {
        var state = ScheduleState()
        state.currentUser = User(iCloudUserID: Self.testICloudUserID, displayName: "テスト")
        let group1 = UserGroup(name: "山田家")
        state.groups = [group1]
        state.currentGroup = group1

        let invalidID = UUID()
        ScheduleReducer.reduce(state: &state, action: .selectGroup(invalidID))

        // currentGroupは変更されない
        #expect(state.currentGroup?.id == group1.id)
    }

    @Test
    func reduce_setGroupOwnership_storesOwnershipPerGroup() {
        var state = ScheduleState()
        let groupID = UUID()

        ScheduleReducer.reduce(state: &state, action: .setGroupOwnership(groupID: groupID, isOwner: true))

        #expect(state.groupOwnership[groupID] == true)
    }

    @Test
    func reduce_setGroupOwnership_canSetFalse() {
        var state = ScheduleState()
        let groupID = UUID()
        state.groupOwnership[groupID] = true

        ScheduleReducer.reduce(state: &state, action: .setGroupOwnership(groupID: groupID, isOwner: false))

        #expect(state.groupOwnership[groupID] == false)
    }

    @Test
    func state_isCurrentGroupOwner_returnsTrueWhenOwner() {
        var state = ScheduleState()
        let group = UserGroup(name: "テスト")
        state.currentGroup = group
        state.groupOwnership[group.id] = true

        #expect(state.isCurrentGroupOwner == true)
    }

    @Test
    func state_isCurrentGroupOwner_returnsFalseWhenNotOwner() {
        var state = ScheduleState()
        let group = UserGroup(name: "テスト")
        state.currentGroup = group
        state.groupOwnership[group.id] = false

        #expect(state.isCurrentGroupOwner == false)
    }

    @Test
    func state_isCurrentGroupOwner_returnsTrueWhenNoOwnershipInfo() {
        var state = ScheduleState()
        let group = UserGroup(name: "テスト")
        state.currentGroup = group
        // groupOwnershipにエントリなし

        // デフォルトはtrueを返す（後方互換性）
        #expect(state.isCurrentGroupOwner == true)
    }

    @Test
    func state_isCurrentGroupOwner_returnsTrueWhenNoGroup() {
        let state = ScheduleState()
        // currentGroupがnil

        #expect(state.isCurrentGroupOwner == true)
    }

    @Test
    func reduce_groupCreated_addsToGroupsArray() {
        var state = ScheduleState()
        state.isCreatingGroup = true
        let existingGroup = UserGroup(name: "既存グループ")
        state.groups = [existingGroup]

        let newGroup = UserGroup(name: "新規グループ")
        ScheduleReducer.reduce(state: &state, action: .groupCreated(newGroup))

        #expect(state.groups.count == 2)
        #expect(state.groups.contains { $0.id == newGroup.id })
        #expect(state.currentGroup?.id == newGroup.id)
    }

    // MARK: - Group Deletion Tests

    @Test
    func reduce_setDeletingGroup_true_setsFlag() {
        var state = ScheduleState()

        ScheduleReducer.reduce(state: &state, action: .setDeletingGroup(true))

        #expect(state.isDeletingGroup == true)
    }

    @Test
    func reduce_setDeletingGroup_false_clearsFlag() {
        var state = ScheduleState()
        state.isDeletingGroup = true

        ScheduleReducer.reduce(state: &state, action: .setDeletingGroup(false))

        #expect(state.isDeletingGroup == false)
    }

    @Test
    func reduce_groupDeleted_removesFromGroupsAndSelectsNext() {
        var state = ScheduleState()
        let group1 = UserGroup(name: "グループ1")
        let group2 = UserGroup(name: "グループ2")
        state.groups = [group1, group2]
        state.currentGroup = group1
        state.isDeletingGroup = true
        state.groupOwnership[group1.id] = true
        state.groupOwnership[group2.id] = false

        ScheduleReducer.reduce(state: &state, action: .groupDeleted(group1.id))

        #expect(state.isDeletingGroup == false)
        #expect(state.groups.count == 1)
        #expect(state.groups.first?.id == group2.id)
        #expect(state.currentGroup?.id == group2.id)  // 自動切り替え
        #expect(state.groupOwnership[group1.id] == nil)
    }

    @Test
    func reduce_groupDeleted_lastGroup_clearsCurrentGroup() {
        var state = ScheduleState()
        let group = UserGroup(name: "唯一のグループ")
        state.groups = [group]
        state.currentGroup = group
        state.isDeletingGroup = true

        ScheduleReducer.reduce(state: &state, action: .groupDeleted(group.id))

        #expect(state.isDeletingGroup == false)
        #expect(state.groups.isEmpty)
        #expect(state.currentGroup == nil)
    }

    @Test
    func reduce_groupDeletionFailed_clearsLoadingAndSetsError() {
        var state = ScheduleState()
        state.isDeletingGroup = true

        ScheduleReducer.reduce(state: &state, action: .groupDeletionFailed("削除に失敗しました"))

        #expect(state.isDeletingGroup == false)
        #expect(state.errorMessage == "削除に失敗しました")
    }

    @Test
    func state_isDeletingGroup_startsAsFalse() {
        let state = ScheduleState()
        #expect(state.isDeletingGroup == false)
    }
}
