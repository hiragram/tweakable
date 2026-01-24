import Testing
import Foundation
@testable import AppCore

@Suite
struct MyAssignmentsReducerTests {

    // MARK: - Test Constants

    private let testUserID = UUID()
    private let testGroupID = UUID()
    private let testGroupName = "テストグループ"

    // MARK: - Test Helpers

    private func createTestDate(daysFromToday: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: daysFromToday, to: today)!
    }

    // MARK: - filterMyAssignments Tests - 今日以降のみフィルタリング

    @Test
    func filterMyAssignments_excludesPastDates() {
        let yesterday = createTestDate(daysFromToday: -1)
        let tomorrow = createTestDate(daysFromToday: 1)
        let today = createTestDate(daysFromToday: 0)

        let assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = [
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: yesterday, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            )),
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: tomorrow, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            ))
        ]

        let result = MyAssignmentsReducer.filterMyAssignments(
            assignments: assignments, userID: testUserID, today: today
        )

        #expect(result.count == 1)
        #expect(Calendar.current.isDate(result[0].date, inSameDayAs: tomorrow))
    }

    @Test
    func filterMyAssignments_includesToday() {
        let today = createTestDate(daysFromToday: 0)

        let assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = [
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: today, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            ))
        ]

        let result = MyAssignmentsReducer.filterMyAssignments(
            assignments: assignments, userID: testUserID, today: today
        )

        #expect(result.count == 1)
    }

    // MARK: - filterMyAssignments Tests - 自分の担当のみ抽出

    @Test
    func filterMyAssignments_extractsOnlyOwnAssignments() {
        let tomorrow = createTestDate(daysFromToday: 1)
        let today = createTestDate(daysFromToday: 0)
        let otherUserID = UUID()

        let assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = [
            // 自分が送り担当
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: tomorrow, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            )),
            // 他の人が担当
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: tomorrow, userGroupID: testGroupID, assignedDropOffUserID: otherUserID
            ))
        ]

        let result = MyAssignmentsReducer.filterMyAssignments(
            assignments: assignments, userID: testUserID, today: today
        )

        #expect(result.count == 1)
        #expect(result[0].assignmentType == MyAssignmentType.dropOff)
    }

    // MARK: - filterMyAssignments Tests - 送りと迎えを別々に抽出

    @Test
    func filterMyAssignments_extractsDropOffAndPickUpSeparately() {
        let tomorrow = createTestDate(daysFromToday: 1)
        let today = createTestDate(daysFromToday: 0)

        let assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = [
            // 自分が送りと迎え両方担当
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: tomorrow,
                userGroupID: testGroupID,
                assignedDropOffUserID: testUserID,
                assignedPickUpUserID: testUserID
            ))
        ]

        let result = MyAssignmentsReducer.filterMyAssignments(
            assignments: assignments, userID: testUserID, today: today
        )

        #expect(result.count == 2)
        #expect(result.contains { $0.assignmentType == MyAssignmentType.dropOff })
        #expect(result.contains { $0.assignmentType == MyAssignmentType.pickUp })
    }

    @Test
    func filterMyAssignments_sortsByDateAscending() {
        let dayAfterTomorrow = createTestDate(daysFromToday: 2)
        let tomorrow = createTestDate(daysFromToday: 1)
        let today = createTestDate(daysFromToday: 0)

        let assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = [
            // 順序をシャッフルして渡す
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: dayAfterTomorrow, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            )),
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: tomorrow, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            ))
        ]

        let result = MyAssignmentsReducer.filterMyAssignments(
            assignments: assignments, userID: testUserID, today: today
        )

        #expect(result.count == 2)
        #expect(result[0].date < result[1].date)
    }

    @Test
    func filterMyAssignments_includesGroupInfo() {
        let tomorrow = createTestDate(daysFromToday: 1)
        let today = createTestDate(daysFromToday: 0)

        let assignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = [
            (groupID: testGroupID, groupName: testGroupName, assignment: DayAssignment(
                date: tomorrow, userGroupID: testGroupID, assignedDropOffUserID: testUserID
            ))
        ]

        let result = MyAssignmentsReducer.filterMyAssignments(
            assignments: assignments, userID: testUserID, today: today
        )

        #expect(result[0].groupID == testGroupID)
        #expect(result[0].groupName == testGroupName)
    }

    // MARK: - groupByDate Tests

    @Test
    func groupByDate_groupsItemsByDate() {
        let tomorrow = createTestDate(daysFromToday: 1)
        let dayAfterTomorrow = createTestDate(daysFromToday: 2)

        let items = [
            MyAssignmentItem(date: tomorrow, groupID: testGroupID, groupName: "グループA", assignmentType: .dropOff as MyAssignmentType),
            MyAssignmentItem(date: tomorrow, groupID: UUID(), groupName: "グループB", assignmentType: .pickUp as MyAssignmentType),
            MyAssignmentItem(date: dayAfterTomorrow, groupID: testGroupID, groupName: "グループA", assignmentType: .dropOff as MyAssignmentType)
        ]

        let result = MyAssignmentsReducer.groupByDate(items)

        #expect(result.keys.count == 2)
        let tomorrowKey = Calendar.current.startOfDay(for: tomorrow)
        let dayAfterTomorrowKey = Calendar.current.startOfDay(for: dayAfterTomorrow)
        #expect(result[tomorrowKey]?.count == 2)
        #expect(result[dayAfterTomorrowKey]?.count == 1)
    }

    @Test
    func groupByDate_emptyInput_returnsEmptyDictionary() {
        let result = MyAssignmentsReducer.groupByDate([])

        #expect(result.isEmpty)
    }

    // MARK: - Reducer Action Tests - loadMyAssignments

    @Test
    func reduce_loadMyAssignments_setsLoadingTrue() {
        var state = MyAssignmentsState()

        MyAssignmentsReducer.reduce(state: &state, action: .loadMyAssignments)

        #expect(state.isLoading == true)
        #expect(state.errorMessage == nil)
    }

    // MARK: - Reducer Action Tests - myAssignmentsLoaded

    @Test
    func reduce_myAssignmentsLoaded_setsAssignmentsAndClearsLoading() {
        var state = MyAssignmentsState()
        state.isLoading = true

        let items = [
            MyAssignmentItem(date: Date(), groupID: testGroupID, groupName: testGroupName, assignmentType: .dropOff as MyAssignmentType)
        ]

        MyAssignmentsReducer.reduce(state: &state, action: .myAssignmentsLoaded(items))

        #expect(state.myAssignments.count == 1)
        #expect(state.isLoading == false)
    }

    // MARK: - Reducer Action Tests - setLoading

    @Test
    func reduce_setLoading_setsIsLoading() {
        var state = MyAssignmentsState()

        MyAssignmentsReducer.reduce(state: &state, action: .setLoading(true))
        #expect(state.isLoading == true)

        MyAssignmentsReducer.reduce(state: &state, action: .setLoading(false))
        #expect(state.isLoading == false)
    }

    // MARK: - Reducer Action Tests - errorOccurred

    @Test
    func reduce_errorOccurred_setsErrorAndClearsLoading() {
        var state = MyAssignmentsState()
        state.isLoading = true

        MyAssignmentsReducer.reduce(state: &state, action: .errorOccurred("テストエラー"))

        #expect(state.errorMessage == "テストエラー")
        #expect(state.isLoading == false)
    }

    // MARK: - Reducer Action Tests - clearError

    @Test
    func reduce_clearError_clearsErrorMessage() {
        var state = MyAssignmentsState()
        state.errorMessage = "既存のエラー"

        MyAssignmentsReducer.reduce(state: &state, action: .clearError)

        #expect(state.errorMessage == nil)
    }
}
