import Testing
import Foundation
import CoreLocation
@testable import AppCore

@Suite
struct WeatherServiceTests {

    // MARK: - Protocol Tests

    @Test
    func weatherService_conformsToProtocol() async throws {
        let service = MockWeatherService()
        // Protocol conformance check - if this compiles, it passes
        let _: any WeatherServiceProtocol = service
    }

    // MARK: - Fetch Weather Tests

    @Test
    func fetchWeather_returnsWeatherData() async throws {
        let service = MockWeatherService()
        let location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )
        let targetDate = Date()

        let weather = try await service.fetchWeather(for: location, targetDate: targetDate)

        #expect(weather.locationID == location.id)
        #expect(weather.locationLabel == location.label)
    }

    @Test
    func fetchWeather_setsCorrectTargetDate() async throws {
        let service = MockWeatherService()
        let location = WeatherLocation(
            label: "保育園",
            latitude: 35.6812,
            longitude: 139.7671,
            placeName: "東京都新宿区",
            userGroupID: UUID()
        )
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

        let weather = try await service.fetchWeather(for: location, targetDate: tomorrow)

        #expect(Calendar.current.isDate(weather.targetDate, inSameDayAs: tomorrow))
    }

    @Test
    func fetchWeatherForLocations_returnsMultipleWeathers() async throws {
        let service = MockWeatherService()
        let userGroupID = UUID()
        let locations = [
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
        let targetDate = Date()

        let weathers = try await service.fetchWeather(for: locations, targetDate: targetDate)

        #expect(weathers.count == 2)
        #expect(weathers[0].locationLabel == "家")
        #expect(weathers[1].locationLabel == "保育園")
    }

    @Test
    func fetchWeather_emptyLocations_returnsEmpty() async throws {
        let service = MockWeatherService()
        let locations: [WeatherLocation] = []
        let targetDate = Date()

        let weathers = try await service.fetchWeather(for: locations, targetDate: targetDate)

        #expect(weathers.isEmpty)
    }

    // MARK: - Error Handling Tests

    @Test
    func fetchWeather_whenServiceFails_throwsError() async {
        let service = MockWeatherService()
        service.shouldFail = true
        let location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )

        await #expect(throws: WeatherServiceError.self) {
            _ = try await service.fetchWeather(for: location, targetDate: Date())
        }
    }
}
