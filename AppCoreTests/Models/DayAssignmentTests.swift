import Testing
import Foundation
@testable import AppCore

@Suite
struct DayAssignmentTests {

    // MARK: - Test Helpers

    private let testUserGroupID = UUID()
    private let testDropOffUserID = UUID()
    private let testPickUpUserID = UUID()

    // MARK: - Initialization Tests

    @Test
    func dayAssignment_init_setsDate() {
        let date = Date()
        let assignment = DayAssignment(date: date, userGroupID: testUserGroupID)
        // 日付は正規化されるので、同じ日であることを確認
        #expect(Calendar.current.isDate(assignment.date, inSameDayAs: date))
    }

    @Test
    func dayAssignment_init_setsUserGroupID() {
        let date = Date()
        let assignment = DayAssignment(date: date, userGroupID: testUserGroupID)
        #expect(assignment.userGroupID == testUserGroupID)
    }

    @Test
    func dayAssignment_init_setsDefaultAssignedDropOffUserIDToNil() {
        let assignment = DayAssignment(date: Date(), userGroupID: testUserGroupID)
        #expect(assignment.assignedDropOffUserID == nil)
    }

    @Test
    func dayAssignment_init_setsDefaultAssignedPickUpUserIDToNil() {
        let assignment = DayAssignment(date: Date(), userGroupID: testUserGroupID)
        #expect(assignment.assignedPickUpUserID == nil)
    }

    @Test
    func dayAssignment_init_canSetAssignedDropOffUserID() {
        let assignment = DayAssignment(
            date: Date(),
            userGroupID: testUserGroupID,
            assignedDropOffUserID: testDropOffUserID
        )
        #expect(assignment.assignedDropOffUserID == testDropOffUserID)
    }

    @Test
    func dayAssignment_init_canSetAssignedPickUpUserID() {
        let assignment = DayAssignment(
            date: Date(),
            userGroupID: testUserGroupID,
            assignedPickUpUserID: testPickUpUserID
        )
        #expect(assignment.assignedPickUpUserID == testPickUpUserID)
    }

    // MARK: - dayOfWeek Tests

    @Test
    func dayAssignment_dayOfWeek_formatsMondayCorrectly() {
        // 2025-01-06 is Monday
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 6))!
        let assignment = DayAssignment(date: date, userGroupID: testUserGroupID)
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        let expected = formatter.string(from: date)
        #expect(assignment.dayOfWeek == expected)
    }

    // MARK: - monthDay Tests

    @Test
    func dayAssignment_monthDay_formatsSingleDigitCorrectly() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5))!
        let assignment = DayAssignment(date: date, userGroupID: testUserGroupID)
        #expect(assignment.monthDay == "1/5")
    }

    @Test
    func dayAssignment_monthDay_formatsDoubleDigitCorrectly() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25))!
        let assignment = DayAssignment(date: date, userGroupID: testUserGroupID)
        #expect(assignment.monthDay == "12/25")
    }

    // MARK: - Identifiable Tests

    @Test
    func dayAssignment_id_isUnique() {
        let date = Date()
        let assignment1 = DayAssignment(date: date, userGroupID: testUserGroupID)
        let assignment2 = DayAssignment(date: date, userGroupID: testUserGroupID)
        #expect(assignment1.id != assignment2.id)
    }
}
