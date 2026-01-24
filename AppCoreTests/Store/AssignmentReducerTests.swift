import Testing
import Foundation
@testable import AppCore

@Suite
struct AssignmentReducerTests {

    // MARK: - Test Constants

    private let testUserGroupID = UUID()

    // MARK: - Test Helpers

    private func createStateWithGroup() -> AssignmentState {
        var state = AssignmentState()
        state.currentGroupID = testUserGroupID
        return state
    }

    private func createWeekAssignments(startDate: Date, userGroupID: UUID) -> [DayAssignment] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else {
                return nil
            }
            return DayAssignment(date: date, userGroupID: userGroupID)
        }
    }

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = AssignmentState()

        #expect(state.weekAssignments.isEmpty)
        #expect(state.weekStartDate == Calendar.current.startOfDay(for: Date()))
        #expect(state.isLoading == false)
        #expect(state.isSaving == false)
        #expect(state.errorMessage == nil)
        #expect(state.currentGroupID == nil)
    }

    // MARK: - Initialize Week Assignments Tests

    @Test
    func reduce_initializeWeekAssignments_createsSevenEntries() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())

        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        #expect(state.weekAssignments.count == 7)
        #expect(state.weekStartDate == weekStart)
        #expect(state.weekAssignments.allSatisfy { $0.userGroupID == testUserGroupID })
        #expect(state.weekAssignments.allSatisfy { $0.assignedDropOffUserID == nil })
        #expect(state.weekAssignments.allSatisfy { $0.assignedPickUpUserID == nil })
    }

    @Test
    func reduce_initializeWeekAssignments_withoutGroup_doesNothing() {
        var state = AssignmentState()
        let weekStart = Date()

        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        #expect(state.weekAssignments.isEmpty)
    }

    // MARK: - Load Week Assignments Tests

    @Test
    func reduce_loadWeekAssignments_setsLoading() {
        var state = AssignmentState()
        let weekStart = Date()

        AssignmentReducer.reduce(state: &state, action: .loadWeekAssignments(weekStartDate: weekStart))

        #expect(state.isLoading == true)
        #expect(state.weekStartDate == weekStart)
    }

    @Test
    func reduce_weekAssignmentsLoaded_mergesEntries() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        state.weekStartDate = weekStart
        state.isLoading = true

        let dropOffUserID = UUID()
        let existingAssignment = DayAssignment(
            date: weekStart,
            userGroupID: testUserGroupID,
            assignedDropOffUserID: dropOffUserID
        )

        AssignmentReducer.reduce(state: &state, action: .weekAssignmentsLoaded([existingAssignment]))

        #expect(state.isLoading == false)
        #expect(state.weekAssignments.count == 7)
        #expect(state.weekAssignments.first?.assignedDropOffUserID == dropOffUserID)
    }

    // MARK: - Update Assignment Tests

    @Test
    func reduce_updateAssignment_setsDropOffUser() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        let dropOffUserID = UUID()
        AssignmentReducer.reduce(state: &state, action: .updateAssignment(index: 0, dropOffUserID: dropOffUserID, pickUpUserID: nil))

        #expect(state.weekAssignments[0].assignedDropOffUserID == dropOffUserID)
        #expect(state.weekAssignments[0].assignedPickUpUserID == nil)
    }

    @Test
    func reduce_updateAssignment_setsPickUpUser() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        let pickUpUserID = UUID()
        AssignmentReducer.reduce(state: &state, action: .updateAssignment(index: 0, dropOffUserID: nil, pickUpUserID: pickUpUserID))

        #expect(state.weekAssignments[0].assignedDropOffUserID == nil)
        #expect(state.weekAssignments[0].assignedPickUpUserID == pickUpUserID)
    }

    @Test
    func reduce_updateAssignment_setsBothUsers() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        let dropOffUserID = UUID()
        let pickUpUserID = UUID()
        AssignmentReducer.reduce(state: &state, action: .updateAssignment(index: 2, dropOffUserID: dropOffUserID, pickUpUserID: pickUpUserID))

        #expect(state.weekAssignments[2].assignedDropOffUserID == dropOffUserID)
        #expect(state.weekAssignments[2].assignedPickUpUserID == pickUpUserID)
    }

    @Test
    func reduce_updateAssignment_clearsDropOffUser() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        // First set a user
        let dropOffUserID = UUID()
        AssignmentReducer.reduce(state: &state, action: .updateAssignment(index: 0, dropOffUserID: dropOffUserID, pickUpUserID: nil))
        #expect(state.weekAssignments[0].assignedDropOffUserID == dropOffUserID)

        // Then clear using clearDropOff action
        AssignmentReducer.reduce(state: &state, action: .clearDropOffAssignment(index: 0))
        #expect(state.weekAssignments[0].assignedDropOffUserID == nil)
    }

    @Test
    func reduce_updateAssignment_clearsPickUpUser() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        // First set a user
        let pickUpUserID = UUID()
        AssignmentReducer.reduce(state: &state, action: .updateAssignment(index: 0, dropOffUserID: nil, pickUpUserID: pickUpUserID))
        #expect(state.weekAssignments[0].assignedPickUpUserID == pickUpUserID)

        // Then clear using clearPickUp action
        AssignmentReducer.reduce(state: &state, action: .clearPickUpAssignment(index: 0))
        #expect(state.weekAssignments[0].assignedPickUpUserID == nil)
    }

    @Test
    func reduce_updateAssignment_invalidIndex_doesNothing() {
        var state = createStateWithGroup()
        let weekStart = Calendar.current.startOfDay(for: Date())
        AssignmentReducer.reduce(state: &state, action: .initializeWeekAssignments(weekStartDate: weekStart))

        let assignmentsBefore = state.weekAssignments
        AssignmentReducer.reduce(state: &state, action: .updateAssignment(index: 100, dropOffUserID: UUID(), pickUpUserID: nil))

        #expect(state.weekAssignments.count == assignmentsBefore.count)
    }

    // MARK: - Submit Tests

    @Test
    func reduce_submitAssignments_setsSaving() {
        var state = AssignmentState()

        AssignmentReducer.reduce(state: &state, action: .submitAssignments)

        #expect(state.isSaving == true)
    }

    @Test
    func reduce_submitCompleted_clearsSavingAndUpdatesEntries() {
        var state = AssignmentState()
        state.isSaving = true

        let savedAssignments = createWeekAssignments(startDate: Date(), userGroupID: testUserGroupID)

        AssignmentReducer.reduce(state: &state, action: .submitCompleted(savedAssignments))

        #expect(state.isSaving == false)
        #expect(state.weekAssignments.count == 7)
    }

    // MARK: - Loading Actions Tests

    @Test
    func reduce_setLoading_true_setsIsLoading() {
        var state = AssignmentState()

        AssignmentReducer.reduce(state: &state, action: .setLoading(true))

        #expect(state.isLoading == true)
    }

    @Test
    func reduce_setLoading_false_clearsIsLoading() {
        var state = AssignmentState()
        state.isLoading = true

        AssignmentReducer.reduce(state: &state, action: .setLoading(false))

        #expect(state.isLoading == false)
    }

    @Test
    func reduce_setSaving_true_setsIsSaving() {
        var state = AssignmentState()

        AssignmentReducer.reduce(state: &state, action: .setSaving(true))

        #expect(state.isSaving == true)
    }

    @Test
    func reduce_setSaving_false_clearsIsSaving() {
        var state = AssignmentState()
        state.isSaving = true

        AssignmentReducer.reduce(state: &state, action: .setSaving(false))

        #expect(state.isSaving == false)
    }

    // MARK: - Error Actions Tests

    @Test
    func reduce_errorOccurred_setsErrorMessage() {
        var state = AssignmentState()
        state.isLoading = true
        state.isSaving = true

        AssignmentReducer.reduce(state: &state, action: .errorOccurred("テストエラー"))

        #expect(state.errorMessage == "テストエラー")
        #expect(state.isLoading == false)
        #expect(state.isSaving == false)
    }

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = AssignmentState()
        state.errorMessage = "既存のエラー"

        AssignmentReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }

    // MARK: - Group ID Tests

    @Test
    func reduce_setCurrentGroupID_setsGroupID() {
        var state = AssignmentState()
        let groupID = UUID()

        AssignmentReducer.reduce(state: &state, action: .setCurrentGroupID(groupID))

        #expect(state.currentGroupID == groupID)
    }
}
