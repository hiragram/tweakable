import Foundation

/// 天気予報サービスのエラー
public enum WeatherServiceError: Error, Sendable {
    case networkError
    case locationNotFound
    case serviceUnavailable
    case unknown(String)
}

/// 天気予報サービスのプロトコル
public protocol WeatherServiceProtocol: Sendable {
    /// 指定した地点の天気を取得
    /// - Parameters:
    ///   - location: 天気を取得する地点
    ///   - targetDate: 取得する日付（今日または明日）
    /// - Returns: 天気データ
    func fetchWeather(for location: WeatherLocation, targetDate: Date) async throws -> HomeWeatherData

    /// 複数地点の天気を取得
    /// - Parameters:
    ///   - locations: 天気を取得する地点のリスト
    ///   - targetDate: 取得する日付
    /// - Returns: 各地点の天気データ
    func fetchWeather(for locations: [WeatherLocation], targetDate: Date) async throws -> [HomeWeatherData]

    /// 指定した地点の週間天気を取得
    /// - Parameters:
    ///   - location: 天気を取得する地点
    ///   - dates: 取得する日付のリスト（7日分など）
    /// - Returns: 各日の天気アイコン名の辞書（Date -> iconName）
    func fetchWeeklyWeatherIcons(for location: WeatherLocation, dates: [Date]) async throws -> [Date: String]
}

/// デフォルト実装
public extension WeatherServiceProtocol {
    func fetchWeather(for locations: [WeatherLocation], targetDate: Date) async throws -> [HomeWeatherData] {
        var results: [HomeWeatherData] = []
        for location in locations {
            let weather = try await fetchWeather(for: location, targetDate: targetDate)
            results.append(weather)
        }
        return results
    }
}
