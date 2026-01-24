import Foundation
import WeatherKit
@testable import AppCore

/// WeatherServiceのMock実装
final class MockWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    /// テスト用: エラーを発生させるかどうか
    var shouldFail = false

    /// テスト用: 返す天気データをカスタマイズ
    var customWeatherData: HomeWeatherData?

    func fetchWeather(for location: WeatherLocation, targetDate: Date) async throws -> HomeWeatherData {
        if shouldFail {
            throw WeatherServiceError.serviceUnavailable
        }

        if let custom = customWeatherData {
            return custom
        }

        // デフォルトのモック天気データを返す
        return HomeWeatherData(
            locationID: location.id,
            locationLabel: location.label,
            targetDate: targetDate,
            iconName: "sun.max.fill",
            condition: .clear,
            highTemperature: 22,
            lowTemperature: 14,
            precipitationChance: 10
        )
    }

    func fetchWeeklyWeatherIcons(for location: WeatherLocation, dates: [Date]) async throws -> [Date: String] {
        if shouldFail {
            throw WeatherServiceError.serviceUnavailable
        }

        // デフォルトのモック週間天気データを返す
        let calendar = Calendar.current
        var result: [Date: String] = [:]
        let icons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.rain.fill"]
        for (index, date) in dates.enumerated() {
            result[calendar.startOfDay(for: date)] = icons[index % icons.count]
        }
        return result
    }
}
