import Testing
import Foundation
@testable import AppCore

@Suite
struct DayScheduleEntryTests {

    // MARK: - Test Helpers

    private let testUserID = UUID()
    private let testUserGroupID = UUID()

    // MARK: - Initialization Tests

    @Test
    func dayScheduleEntry_init_setsDate() {
        let date = Date()
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        // 日付は正規化されるので、同じ日であることを確認
        #expect(Calendar.current.isDate(entry.date, inSameDayAs: date))
    }

    @Test
    func dayScheduleEntry_init_setsUserID() {
        let date = Date()
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry.userID == testUserID)
    }

    @Test
    func dayScheduleEntry_init_setsUserGroupID() {
        let date = Date()
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry.userGroupID == testUserGroupID)
    }

    @Test
    func dayScheduleEntry_init_setsDefaultDropOffStatusToNotSet() {
        let entry = DayScheduleEntry(date: Date(), userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry.dropOffStatus == .notSet)
    }

    @Test
    func dayScheduleEntry_init_setsDefaultPickUpStatusToNotSet() {
        let entry = DayScheduleEntry(date: Date(), userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry.pickUpStatus == .notSet)
    }

    @Test
    func dayScheduleEntry_init_canSetDropOffStatus() {
        let entry = DayScheduleEntry(date: Date(), userID: testUserID, userGroupID: testUserGroupID, dropOffStatus: .ok)
        #expect(entry.dropOffStatus == .ok)
    }

    @Test
    func dayScheduleEntry_init_canSetPickUpStatus() {
        let entry = DayScheduleEntry(date: Date(), userID: testUserID, userGroupID: testUserGroupID, pickUpStatus: .ng)
        #expect(entry.pickUpStatus == .ng)
    }

    // MARK: - dayOfWeek Tests

    @Test
    func dayScheduleEntry_dayOfWeek_formatsMondayCorrectly() {
        // 2025-01-06 is Monday
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 6))!
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        // Expected value depends on current locale
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        let expected = formatter.string(from: date)
        #expect(entry.dayOfWeek == expected)
    }

    @Test
    func dayScheduleEntry_dayOfWeek_formatsSundayCorrectly() {
        // 2025-01-05 is Sunday
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5))!
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        // Expected value depends on current locale
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        let expected = formatter.string(from: date)
        #expect(entry.dayOfWeek == expected)
    }

    // MARK: - monthDay Tests

    @Test
    func dayScheduleEntry_monthDay_formatsSingleDigitCorrectly() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 5))!
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry.monthDay == "1/5")
    }

    @Test
    func dayScheduleEntry_monthDay_formatsDoubleDigitCorrectly() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25))!
        let entry = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry.monthDay == "12/25")
    }

    // MARK: - Identifiable Tests

    @Test
    func dayScheduleEntry_id_isUnique() {
        let date = Date()
        let entry1 = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        let entry2 = DayScheduleEntry(date: date, userID: testUserID, userGroupID: testUserGroupID)
        #expect(entry1.id != entry2.id)
    }
}
