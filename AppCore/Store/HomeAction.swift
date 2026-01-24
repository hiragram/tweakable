import Foundation

/// Home screen actions
public enum HomeAction: Sendable {
    // MARK: - Data Sync Actions

    /// Sync home state from schedule state
    case syncFromScheduleState

    /// Update today's schedule display
    case updateTodaySchedule(dropOff: HomeAssignmentStatus, pickUp: HomeAssignmentStatus)

    /// Update weekly schedule display
    case updateWeekSchedule([HomeDaySchedule])

    /// Update current user name
    case updateCurrentUserName(String)

    // MARK: - Weather Location Actions

    /// Add a weather location
    case addWeatherLocation(WeatherLocation)

    /// Update an existing weather location
    case updateWeatherLocation(WeatherLocation)

    /// Remove a weather location
    case removeWeatherLocation(UUID)

    /// Set all weather locations (from CloudKit sync)
    case setWeatherLocations([WeatherLocation])

    // MARK: - Weather Actions

    /// Load weather data for all locations
    case loadWeather

    /// Weather data loaded successfully (legacy single location)
    case weatherLoaded(HomeWeatherData)

    /// Weather data loaded for all locations
    case weathersLoaded([HomeWeatherData])

    /// Weather loading failed
    case weatherLoadFailed(String)

    /// Weekly weather icons loaded successfully for a location
    case weeklyWeatherIconsLoaded(locationID: UUID, icons: [Date: String])

    // MARK: - Navigation Actions

    /// User tapped schedule input button
    case scheduleInputTapped

    // MARK: - Data Clear Actions

    /// Clear all weather-related data (used when switching groups)
    case clearWeatherData

    // MARK: - Refresh Actions

    /// Refresh all home screen data (assignments, weather, etc.)
    case refresh
}
