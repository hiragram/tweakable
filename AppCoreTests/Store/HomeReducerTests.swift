import Testing
import Foundation
import WeatherKit
@testable import AppCore

@Suite
struct HomeReducerTests {

    // MARK: - Update Today Schedule Tests

    @Test
    func reduce_updateTodaySchedule_updatesDropOffAndPickUp() {
        var state = HomeState()

        HomeReducer.reduce(
            state: &state,
            action: .updateTodaySchedule(
                dropOff: .confirmed(personName: "Papa"),
                pickUp: .confirmed(personName: "Mama")
            )
        )

        #expect(state.todayDropOff == .confirmed(personName: "Papa"))
        #expect(state.todayPickUp == .confirmed(personName: "Mama"))
    }

    @Test
    func reduce_updateTodaySchedule_withUnconfirmed() {
        var state = HomeState()
        state.todayDropOff = .confirmed(personName: "Papa")

        HomeReducer.reduce(
            state: &state,
            action: .updateTodaySchedule(dropOff: .unconfirmed, pickUp: .noAssignee)
        )

        #expect(state.todayDropOff == .unconfirmed)
        #expect(state.todayPickUp == .noAssignee)
    }

    // MARK: - Update Week Schedule Tests

    @Test
    func reduce_updateWeekSchedule_setsWeekSchedule() {
        var state = HomeState()
        let today = Date()
        let schedule = [
            HomeDaySchedule(
                date: today,
                dropOff: .confirmed(personName: "Papa"),
                pickUp: .confirmed(personName: "Mama")
            )
        ]

        HomeReducer.reduce(state: &state, action: .updateWeekSchedule(schedule))

        #expect(state.weekSchedule.count == 1)
        #expect(state.weekSchedule[0].dropOff == .confirmed(personName: "Papa"))
    }

    @Test
    func reduce_updateWeekSchedule_replacesExisting() {
        var state = HomeState()
        let today = Date()
        let oldSchedule = [
            HomeDaySchedule(date: today, dropOff: .unconfirmed, pickUp: .unconfirmed)
        ]
        state.weekSchedule = oldSchedule

        let newSchedule = [
            HomeDaySchedule(date: today, dropOff: .confirmed(personName: "Papa"), pickUp: .noAssignee),
            HomeDaySchedule(
                date: Calendar.current.date(byAdding: .day, value: 1, to: today)!,
                dropOff: .confirmed(personName: "Mama"),
                pickUp: .confirmed(personName: "Papa")
            )
        ]

        HomeReducer.reduce(state: &state, action: .updateWeekSchedule(newSchedule))

        #expect(state.weekSchedule.count == 2)
    }

    // MARK: - Update Current User Name Tests

    @Test
    func reduce_updateCurrentUserName_setsName() {
        var state = HomeState()

        HomeReducer.reduce(state: &state, action: .updateCurrentUserName("Papa"))

        #expect(state.currentUserName == "Papa")
    }

    @Test
    func reduce_updateCurrentUserName_updatesExisting() {
        var state = HomeState()
        state.currentUserName = "Mama"

        HomeReducer.reduce(state: &state, action: .updateCurrentUserName("Papa"))

        #expect(state.currentUserName == "Papa")
    }

    // MARK: - Weather Actions Tests

    @Test
    func reduce_loadWeather_setsLoadingState() {
        var state = HomeState()

        HomeReducer.reduce(state: &state, action: .loadWeather)

        #expect(state.isLoadingWeather == true)
    }

    @Test
    func reduce_weatherLoaded_setsWeatherData() {
        var state = HomeState()
        state.isLoadingWeather = true

        let weather = HomeWeatherData(
            iconName: "sun.max.fill",
            highTemperature: 25,
            lowTemperature: 18,
            precipitationChance: 10
        )

        HomeReducer.reduce(state: &state, action: .weatherLoaded(weather))

        #expect(state.isLoadingWeather == false)
        #expect(state.weather?.iconName == "sun.max.fill")
        #expect(state.weather?.highTemperature == 25)
        #expect(state.weather?.lowTemperature == 18)
        #expect(state.weather?.precipitationChance == 10)
    }

    @Test
    func reduce_weatherLoadFailed_clearsLoadingState() {
        var state = HomeState()
        state.isLoadingWeather = true

        HomeReducer.reduce(state: &state, action: .weatherLoadFailed("Network error"))

        #expect(state.isLoadingWeather == false)
        #expect(state.weather == nil)
    }

    // MARK: - Derive Assignment Status Tests

    @Test
    func deriveAssignmentStatus_ok_returnsConfirmed() {
        let result = HomeReducer.deriveAssignmentStatus(from: .ok, userName: "Papa")

        #expect(result == .confirmed(personName: "Papa"))
    }

    @Test
    func deriveAssignmentStatus_ok_withNilUserName_returnsUnconfirmed() {
        let result = HomeReducer.deriveAssignmentStatus(from: .ok, userName: nil)

        #expect(result == .unconfirmed)
    }

    @Test
    func deriveAssignmentStatus_ng_returnsNoAssignee() {
        let result = HomeReducer.deriveAssignmentStatus(from: .ng, userName: "Papa")

        #expect(result == .noAssignee)
    }

    @Test
    func deriveAssignmentStatus_notSet_returnsUnconfirmed() {
        let result = HomeReducer.deriveAssignmentStatus(from: .notSet, userName: "Papa")

        #expect(result == .unconfirmed)
    }

    // MARK: - Generate Warnings Tests

    @Test
    func generateWarnings_allConfirmed_returnsEmpty() {
        let today = Date()
        let schedule = (0..<7).map { offset in
            HomeDaySchedule(
                date: Calendar.current.date(byAdding: .day, value: offset, to: today)!,
                dropOff: .confirmed(personName: "Papa"),
                pickUp: .confirmed(personName: "Mama")
            )
        }

        let warnings = HomeReducer.generateWarnings(from: schedule)

        #expect(warnings.isEmpty)
    }

    @Test
    func generateWarnings_hasUnconfirmed_returnsWarning() {
        let today = Date()
        let schedule = [
            HomeDaySchedule(
                date: today,
                dropOff: .unconfirmed,
                pickUp: .confirmed(personName: "Mama")
            )
        ]

        let warnings = HomeReducer.generateWarnings(from: schedule)

        #expect(warnings.count == 1)
        #expect(warnings[0].type == .unconfirmed)
    }

    @Test
    func generateWarnings_hasNoAssignee_returnsCriticalWarning() {
        let today = Date()
        let schedule = [
            HomeDaySchedule(
                date: today,
                dropOff: .noAssignee,
                pickUp: .confirmed(personName: "Mama")
            )
        ]

        let warnings = HomeReducer.generateWarnings(from: schedule)

        #expect(warnings.count == 1)
        #expect(warnings[0].type == .noAssignee)
    }

    @Test
    func generateWarnings_multipleIssues_returnsSortedWarnings() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let schedule = [
            HomeDaySchedule(
                date: today,
                dropOff: .unconfirmed,
                pickUp: .unconfirmed
            ),
            HomeDaySchedule(
                date: tomorrow,
                dropOff: .noAssignee,
                pickUp: .confirmed(personName: "Papa")
            )
        ]

        let warnings = HomeReducer.generateWarnings(from: schedule)

        // Should have warnings for: today dropOff unconfirmed, today pickUp unconfirmed, tomorrow dropOff noAssignee
        #expect(warnings.count >= 2)
        // noAssignee warnings should come first
        if let firstNoAssigneeIndex = warnings.firstIndex(where: { $0.type == .noAssignee }) {
            let unconfirmedIndices = warnings.indices.filter { warnings[$0].type == .unconfirmed }
            for unconfirmedIndex in unconfirmedIndices {
                #expect(firstNoAssigneeIndex < unconfirmedIndex)
            }
        }
    }

    // MARK: - Initial State Tests

    @Test
    func state_init_hasDefaultValues() {
        let state = HomeState()

        #expect(state.todayDropOff == .unconfirmed)
        #expect(state.todayPickUp == .unconfirmed)
        #expect(state.weekSchedule.isEmpty)
        #expect(state.weather == nil)
        #expect(state.isLoadingWeather == false)
        #expect(state.currentUserName == "")
    }

    // MARK: - HomeDaySchedule Tests

    @Test
    func homeDaySchedule_isToday_returnsTrueForToday() {
        let schedule = HomeDaySchedule(
            date: Date(),
            dropOff: .confirmed(personName: "Papa"),
            pickUp: .confirmed(personName: "Mama")
        )

        #expect(schedule.isToday == true)
    }

    @Test
    func homeDaySchedule_isToday_returnsFalseForTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let schedule = HomeDaySchedule(
            date: tomorrow,
            dropOff: .confirmed(personName: "Papa"),
            pickUp: .confirmed(personName: "Mama")
        )

        #expect(schedule.isToday == false)
    }

    @Test
    func homeDaySchedule_dayOfWeek_returnsLocalizedDay() {
        // Create a known date (2025-01-06 is Monday)
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 6
        let monday = Calendar.current.date(from: components)!

        let schedule = HomeDaySchedule(
            date: monday,
            dropOff: .confirmed(personName: "Papa"),
            pickUp: .confirmed(personName: "Mama")
        )

        // Expected value depends on current locale
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        let expected = formatter.string(from: monday)
        #expect(schedule.dayOfWeek == expected)
    }

    // MARK: - HomeAssignmentStatus Equality Tests

    @Test
    func homeAssignmentStatus_confirmed_equality() {
        let status1 = HomeAssignmentStatus.confirmed(personName: "Papa")
        let status2 = HomeAssignmentStatus.confirmed(personName: "Papa")
        let status3 = HomeAssignmentStatus.confirmed(personName: "Mama")

        #expect(status1 == status2)
        #expect(status1 != status3)
    }

    @Test
    func homeAssignmentStatus_differentTypes_notEqual() {
        let confirmed = HomeAssignmentStatus.confirmed(personName: "Papa")
        let unconfirmed = HomeAssignmentStatus.unconfirmed
        let noAssignee = HomeAssignmentStatus.noAssignee

        #expect(confirmed != unconfirmed)
        #expect(confirmed != noAssignee)
        #expect(unconfirmed != noAssignee)
    }

    // MARK: - Weather Location Tests

    @Test
    func reduce_addWeatherLocation_addsToList() {
        var state = HomeState()
        let location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )

        HomeReducer.reduce(state: &state, action: .addWeatherLocation(location))

        #expect(state.weatherLocations.count == 1)
        #expect(state.weatherLocations[0].label == "家")
    }

    @Test
    func reduce_addWeatherLocation_limitsToMaxTwo() {
        var state = HomeState()
        let userGroupID = UUID()
        let location1 = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )
        let location2 = WeatherLocation(
            label: "保育園",
            latitude: 35.6812,
            longitude: 139.7671,
            placeName: "東京都新宿区",
            userGroupID: userGroupID
        )
        let location3 = WeatherLocation(
            label: "職場",
            latitude: 35.6895,
            longitude: 139.6917,
            placeName: "東京都港区",
            userGroupID: userGroupID
        )

        HomeReducer.reduce(state: &state, action: .addWeatherLocation(location1))
        HomeReducer.reduce(state: &state, action: .addWeatherLocation(location2))
        HomeReducer.reduce(state: &state, action: .addWeatherLocation(location3))

        #expect(state.weatherLocations.count == 2)
    }

    @Test
    func reduce_updateWeatherLocation_updatesExisting() {
        var state = HomeState()
        let userGroupID = UUID()
        let location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )
        state.weatherLocations = [location]

        var updatedLocation = location
        updatedLocation.label = "自宅"
        updatedLocation.placeName = "東京都目黒区"

        HomeReducer.reduce(state: &state, action: .updateWeatherLocation(updatedLocation))

        #expect(state.weatherLocations.count == 1)
        #expect(state.weatherLocations[0].label == "自宅")
        #expect(state.weatherLocations[0].placeName == "東京都目黒区")
    }

    @Test
    func reduce_removeWeatherLocation_removesFromList() {
        var state = HomeState()
        let userGroupID = UUID()
        let location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )
        state.weatherLocations = [location]

        HomeReducer.reduce(state: &state, action: .removeWeatherLocation(location.id))

        #expect(state.weatherLocations.isEmpty)
    }

    @Test
    func reduce_setWeatherLocations_replacesAll() {
        var state = HomeState()
        let userGroupID = UUID()
        let oldLocation = WeatherLocation(
            label: "古い場所",
            latitude: 0,
            longitude: 0,
            placeName: "どこか",
            userGroupID: userGroupID
        )
        state.weatherLocations = [oldLocation]

        let newLocations = [
            WeatherLocation(
                label: "家",
                latitude: 35.6762,
                longitude: 139.6503,
                placeName: "東京都渋谷区",
                userGroupID: userGroupID
            ),
            WeatherLocation(
                label: "保育園",
                latitude: 35.6812,
                longitude: 139.7671,
                placeName: "東京都新宿区",
                userGroupID: userGroupID
            )
        ]

        HomeReducer.reduce(state: &state, action: .setWeatherLocations(newLocations))

        #expect(state.weatherLocations.count == 2)
        #expect(state.weatherLocations[0].label == "家")
        #expect(state.weatherLocations[1].label == "保育園")
    }

    // MARK: - Multi-Location Weather Tests

    @Test
    func reduce_weathersLoaded_setsMultipleWeathers() {
        var state = HomeState()
        state.isLoadingWeather = true
        let locationID1 = UUID()
        let locationID2 = UUID()

        let weathers = [
            HomeWeatherData(
                locationID: locationID1,
                locationLabel: "家",
                targetDate: Date(),
                iconName: "sun.max.fill",
                condition: .clear,
                highTemperature: 25,
                lowTemperature: 18,
                precipitationChance: 10
            ),
            HomeWeatherData(
                locationID: locationID2,
                locationLabel: "保育園",
                targetDate: Date(),
                iconName: "cloud.fill",
                condition: .cloudy,
                highTemperature: 23,
                lowTemperature: 16,
                precipitationChance: 30
            )
        ]

        HomeReducer.reduce(state: &state, action: .weathersLoaded(weathers))

        #expect(state.isLoadingWeather == false)
        #expect(state.weathers.count == 2)
    }

    // MARK: - Weather Target Date Tests

    @Test
    func weatherTargetDate_before19_returnsToday() {
        // 18:00に設定
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        components.hour = 18
        components.minute = 0
        components.second = 0
        let date = Calendar.current.date(from: components)!

        let targetDate = HomeReducer.calculateWeatherTargetDate(currentTime: date)

        #expect(Calendar.current.isDateInToday(targetDate))
    }

    @Test
    func weatherTargetDate_at19_returnsTomorrow() {
        // 19:00に設定
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        components.hour = 19
        components.minute = 0
        components.second = 0
        let date = Calendar.current.date(from: components)!

        let targetDate = HomeReducer.calculateWeatherTargetDate(currentTime: date)

        #expect(Calendar.current.isDateInTomorrow(targetDate))
    }

    @Test
    func weatherTargetDate_after19_returnsTomorrow() {
        // 21:00に設定
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        components.hour = 21
        components.minute = 0
        components.second = 0
        let date = Calendar.current.date(from: components)!

        let targetDate = HomeReducer.calculateWeatherTargetDate(currentTime: date)

        #expect(Calendar.current.isDateInTomorrow(targetDate))
    }

    // MARK: - Derive Assignment Status From Assignment Tests

    @Test
    func deriveAssignmentStatusFromAssignment_assignedToMe_returnsConfirmed() {
        let myUserID = UUID()
        let result = HomeReducer.deriveAssignmentStatusFromAssignment(
            assignedUserID: myUserID,
            currentUserID: myUserID.uuidString,
            currentUserName: "パパ"
        )

        #expect(result == .confirmed(personName: "パパ"))
    }

    @Test
    func deriveAssignmentStatusFromAssignment_assignedToOther_returnsConfirmedEmpty() {
        let otherUserID = UUID()
        let myUserID = UUID()
        let result = HomeReducer.deriveAssignmentStatusFromAssignment(
            assignedUserID: otherUserID,
            currentUserID: myUserID.uuidString,
            currentUserName: "パパ"
        )

        // 他人が担当の場合は空文字で表示（自分かどうかだけ分かればいい）
        #expect(result == .confirmed(personName: ""))
    }

    @Test
    func deriveAssignmentStatusFromAssignment_notAssigned_returnsUnconfirmed() {
        let myUserID = UUID()
        let result = HomeReducer.deriveAssignmentStatusFromAssignment(
            assignedUserID: nil,
            currentUserID: myUserID.uuidString,
            currentUserName: "パパ"
        )

        #expect(result == .unconfirmed)
    }

    // MARK: - Refresh Tests

    @Test
    func reduce_refresh_doesNotChangeState() {
        var state = HomeState()
        // Set up some initial state
        state.todayDropOff = .confirmed(personName: "Papa")
        state.todayPickUp = .confirmed(personName: "Mama")
        state.weekSchedule = [
            HomeDaySchedule(
                date: Date(),
                dropOff: .confirmed(personName: "Papa"),
                pickUp: .confirmed(personName: "Mama")
            )
        ]
        state.currentUserName = "Papa"
        state.isLoadingWeather = false

        // Store original state for comparison
        let originalDropOff = state.todayDropOff
        let originalPickUp = state.todayPickUp
        let originalScheduleCount = state.weekSchedule.count
        let originalUserName = state.currentUserName
        let originalLoadingWeather = state.isLoadingWeather

        // Refresh action should not change any state (side effects only)
        HomeReducer.reduce(state: &state, action: .refresh)

        #expect(state.todayDropOff == originalDropOff)
        #expect(state.todayPickUp == originalPickUp)
        #expect(state.weekSchedule.count == originalScheduleCount)
        #expect(state.currentUserName == originalUserName)
        #expect(state.isLoadingWeather == originalLoadingWeather)
    }

    // MARK: - Clear Weather Data Tests

    @Test
    func reduce_clearWeatherData_clearsAllWeatherRelatedState() {
        var state = HomeState()
        let userGroupID = UUID()
        let locationID = UUID()

        // Set up state with weather data
        state.weatherLocations = [
            WeatherLocation(
                label: "家",
                latitude: 35.6762,
                longitude: 139.6503,
                placeName: "東京都渋谷区",
                userGroupID: userGroupID
            )
        ]
        state.weathers = [
            HomeWeatherData(
                locationID: locationID,
                locationLabel: "家",
                targetDate: Date(),
                iconName: "sun.max.fill",
                condition: .clear,
                highTemperature: 25,
                lowTemperature: 18,
                precipitationChance: 10
            )
        ]
        state.weeklyWeatherIconsByLocation = [
            locationID: [Date(): "sun.max.fill"]
        ]
        state.isLoadingWeather = true

        HomeReducer.reduce(state: &state, action: .clearWeatherData)

        #expect(state.weatherLocations.isEmpty)
        #expect(state.weathers.isEmpty)
        #expect(state.weeklyWeatherIconsByLocation.isEmpty)
        #expect(state.isLoadingWeather == false)
    }
}
