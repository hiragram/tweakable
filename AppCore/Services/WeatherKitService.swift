import Foundation
import WeatherKit
import CoreLocation

/// WeatherKitを使用した天気予報サービス
public actor WeatherKitService: WeatherServiceProtocol {
    private let weatherService = WeatherService.shared

    public init() {}

    public func fetchWeather(for location: WeatherLocation, targetDate: Date) async throws -> HomeWeatherData {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        do {
            let weather = try await weatherService.weather(for: clLocation)

            // targetDateに対応する天気を取得
            let dayWeather = findDayWeather(for: targetDate, in: weather)
            let condition = dayWeather?.condition ?? weather.currentWeather.condition

            return HomeWeatherData(
                locationID: location.id,
                locationLabel: location.label,
                targetDate: targetDate,
                iconName: mapConditionToIcon(condition),
                condition: condition,
                highTemperature: Int(dayWeather?.highTemperature.value ?? weather.currentWeather.temperature.value),
                lowTemperature: Int(dayWeather?.lowTemperature.value ?? weather.currentWeather.temperature.value - 5),
                precipitationChance: Int((dayWeather?.precipitationChance ?? 0) * 100)
            )
        } catch {
            print("[DEBUG] WeatherKit error type: \(type(of: error))")
            print("[DEBUG] WeatherKit error: \(error)")
            print("[DEBUG] WeatherKit localizedDescription: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("[DEBUG] NSError domain: \(nsError.domain)")
                print("[DEBUG] NSError code: \(nsError.code)")
                print("[DEBUG] NSError userInfo: \(nsError.userInfo)")
            }
            throw WeatherServiceError.unknown(error.localizedDescription)
        }
    }

    /// 指定日の天気予報を取得
    private func findDayWeather(for date: Date, in weather: Weather) -> DayWeather? {
        let calendar = Calendar.current
        return weather.dailyForecast.first { dayWeather in
            calendar.isDate(dayWeather.date, inSameDayAs: date)
        }
    }

    /// WeatherKitのConditionをSF Symbolsアイコン名に変換
    private func mapConditionToIcon(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .mostlyClear:
            return "sun.max.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .mostlyCloudy:
            return "cloud.fill"
        case .cloudy:
            return "cloud.fill"
        case .foggy:
            return "cloud.fog.fill"
        case .haze:
            return "sun.haze.fill"
        case .smoky:
            return "smoke.fill"
        case .breezy:
            return "wind"
        case .windy:
            return "wind"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .flurries:
            return "cloud.snow.fill"
        case .snow:
            return "cloud.snow.fill"
        case .heavySnow:
            return "cloud.snow.fill"
        case .sleet:
            return "cloud.sleet.fill"
        case .freezingRain:
            return "cloud.sleet.fill"
        case .freezingDrizzle:
            return "cloud.sleet.fill"
        case .hail:
            return "cloud.hail.fill"
        case .thunderstorms:
            return "cloud.bolt.fill"
        case .isolatedThunderstorms:
            return "cloud.bolt.fill"
        case .scatteredThunderstorms:
            return "cloud.bolt.fill"
        case .strongStorms:
            return "cloud.bolt.rain.fill"
        case .tropicalStorm:
            return "tropicalstorm"
        case .hurricane:
            return "hurricane"
        case .blizzard:
            return "cloud.snow.fill"
        case .blowingSnow:
            return "wind.snow"
        case .blowingDust:
            return "sun.dust.fill"
        case .hot:
            return "sun.max.fill"
        case .sunShowers:
            return "cloud.sun.rain.fill"
        case .wintryMix:
            return "cloud.sleet.fill"
        case .frigid:
            return "thermometer.snowflake"
        default:
            return "cloud.fill"
        }
    }

    public func fetchWeeklyWeatherIcons(for location: WeatherLocation, dates: [Date]) async throws -> [Date: String] {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        do {
            let weather = try await weatherService.weather(for: clLocation)
            var result: [Date: String] = [:]
            let calendar = Calendar.current

            for date in dates {
                if let dayWeather = weather.dailyForecast.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                    result[calendar.startOfDay(for: date)] = mapConditionToIcon(dayWeather.condition)
                }
            }

            return result
        } catch {
            print("[DEBUG] WeatherKit weekly error: \(error)")
            throw WeatherServiceError.unknown(error.localizedDescription)
        }
    }

}
