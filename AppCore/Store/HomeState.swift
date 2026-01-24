import Foundation
import WeatherKit

/// Home screen assignment status (derived from ScheduleState)
public enum HomeAssignmentStatus: Equatable, Sendable {
    /// Confirmed with an assignee name
    case confirmed(personName: String)
    /// Not yet decided
    case unconfirmed
    /// Nobody available - critical state
    case noAssignee
}

/// Daily schedule data for home view display
public struct HomeDaySchedule: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let dropOff: HomeAssignmentStatus
    public let pickUp: HomeAssignmentStatus

    public init(
        id: UUID = UUID(),
        date: Date,
        dropOff: HomeAssignmentStatus,
        pickUp: HomeAssignmentStatus
    ) {
        self.id = id
        self.date = date
        self.dropOff = dropOff
        self.pickUp = pickUp
    }

    /// Day of week (e.g., "月", "火" / "Mon", "Tue")
    public var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    /// Day of month (e.g., "12", "25")
    public var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    /// Whether this date is today
    public var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

/// Weather data for a specific location
public struct HomeWeatherData: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let locationID: UUID
    public let locationLabel: String
    public let targetDate: Date
    public let iconName: String
    public let condition: WeatherCondition
    public let highTemperature: Int
    public let lowTemperature: Int
    public let precipitationChance: Int

    public var conditionDescription: String {
        condition.description
    }

    public init(
        id: UUID = UUID(),
        locationID: UUID,
        locationLabel: String,
        targetDate: Date,
        iconName: String,
        condition: WeatherCondition,
        highTemperature: Int,
        lowTemperature: Int,
        precipitationChance: Int
    ) {
        self.id = id
        self.locationID = locationID
        self.locationLabel = locationLabel
        self.targetDate = targetDate
        self.iconName = iconName
        self.condition = condition
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.precipitationChance = precipitationChance
    }

    // Legacy initializer for backward compatibility
    public init(
        iconName: String,
        highTemperature: Int,
        lowTemperature: Int,
        precipitationChance: Int
    ) {
        self.id = UUID()
        self.locationID = UUID()
        self.locationLabel = ""
        self.targetDate = Date()
        self.iconName = iconName
        self.condition = .clear
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.precipitationChance = precipitationChance
    }
}

/// Warning item to display on home screen
public struct HomeWarning: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let type: WarningType
    public let message: String

    public enum WarningType: Equatable, Sendable {
        /// Red - critical: nobody can handle this slot
        case noAssignee
        /// Yellow - warning: not yet confirmed
        case unconfirmed
    }

    public init(id: UUID = UUID(), type: WarningType, message: String) {
        self.id = id
        self.type = type
        self.message = message
    }
}

/// Home screen state
public struct HomeState: Equatable, Sendable {
    // MARK: - Today's Schedule

    /// Today's drop-off assignment status
    public var todayDropOff: HomeAssignmentStatus = .unconfirmed

    /// Today's pick-up assignment status
    public var todayPickUp: HomeAssignmentStatus = .unconfirmed

    // MARK: - Weekly Schedule

    /// This week's schedule (derived from ScheduleState)
    public var weekSchedule: [HomeDaySchedule] = []

    // MARK: - Weather

    /// Registered weather locations (max 2)
    public var weatherLocations: [WeatherLocation] = []

    /// Weather data for each location
    public var weathers: [HomeWeatherData] = []

    /// Legacy single weather (for backward compatibility)
    public var weather: HomeWeatherData? {
        weathers.first
    }

    /// Whether weather is loading
    public var isLoadingWeather: Bool = false

    /// Weekly weather icons per location (locationID -> (Date -> iconName))
    public var weeklyWeatherIconsByLocation: [UUID: [Date: String]] = [:]

    // MARK: - User

    /// Current user's display name
    public var currentUserName: String = ""

    // MARK: - Computed Properties

    /// Warnings derived from schedule state
    public var warnings: [HomeWarning] {
        // Stub implementation - will be replaced in GREEN phase
        []
    }

    public init() {}
}
