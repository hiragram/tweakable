import Testing
@testable import AppCore

@Suite
struct ScheduleStatusTests {

    // MARK: - next() Tests

    @Test
    func scheduleStatus_next_fromNotSet_returnsOk() {
        let status = ScheduleStatus.notSet
        #expect(status.next() == .ok)
    }

    @Test
    func scheduleStatus_next_fromOk_returnsNg() {
        let status = ScheduleStatus.ok
        #expect(status.next() == .ng)
    }

    @Test
    func scheduleStatus_next_fromNg_returnsNotSet() {
        let status = ScheduleStatus.ng
        #expect(status.next() == .notSet)
    }

    // MARK: - rawValue Tests

    @Test
    func scheduleStatus_rawValue_notSet_isZero() {
        #expect(ScheduleStatus.notSet.rawValue == 0)
    }

    @Test
    func scheduleStatus_rawValue_ok_isOne() {
        #expect(ScheduleStatus.ok.rawValue == 1)
    }

    @Test
    func scheduleStatus_rawValue_ng_isTwo() {
        #expect(ScheduleStatus.ng.rawValue == 2)
    }

    @Test
    func scheduleStatus_initFromRawValue_zero_returnsNotSet() {
        #expect(ScheduleStatus(rawValue: 0) == .notSet)
    }

    @Test
    func scheduleStatus_initFromRawValue_one_returnsOk() {
        #expect(ScheduleStatus(rawValue: 1) == .ok)
    }

    @Test
    func scheduleStatus_initFromRawValue_two_returnsNg() {
        #expect(ScheduleStatus(rawValue: 2) == .ng)
    }

    @Test
    func scheduleStatus_initFromRawValue_invalidValue_returnsNil() {
        #expect(ScheduleStatus(rawValue: 99) == nil)
    }
}
