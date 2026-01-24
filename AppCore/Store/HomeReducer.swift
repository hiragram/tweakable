import Foundation

/// Home screen reducer (pure function)
public enum HomeReducer {
    /// Reduce state based on action (pure function)
    /// - Parameters:
    ///   - state: Current state (inout)
    ///   - action: Action to execute
    public static func reduce(state: inout HomeState, action: HomeAction) {
        switch action {
        case .syncFromScheduleState:
            // This action is handled by Store as a side effect trigger
            break

        case .updateTodaySchedule(let dropOff, let pickUp):
            state.todayDropOff = dropOff
            state.todayPickUp = pickUp

        case .updateWeekSchedule(let schedule):
            state.weekSchedule = schedule

        case .updateCurrentUserName(let name):
            state.currentUserName = name

        case .addWeatherLocation(let location):
            // Max 2 locations
            if state.weatherLocations.count < 2 {
                state.weatherLocations.append(location)
            }

        case .updateWeatherLocation(let location):
            if let index = state.weatherLocations.firstIndex(where: { $0.id == location.id }) {
                state.weatherLocations[index] = location
            }

        case .removeWeatherLocation(let locationID):
            state.weatherLocations.removeAll { $0.id == locationID }

        case .setWeatherLocations(let locations):
            // Limit to max 2
            state.weatherLocations = Array(locations.prefix(2))

        case .loadWeather:
            state.isLoadingWeather = true

        case .weatherLoaded(let weather):
            state.isLoadingWeather = false
            state.weathers = [weather]

        case .weathersLoaded(let weathers):
            state.isLoadingWeather = false
            state.weathers = weathers

        case .weatherLoadFailed:
            state.isLoadingWeather = false
            state.weathers = []

        case .weeklyWeatherIconsLoaded(let locationID, let icons):
            state.weeklyWeatherIconsByLocation[locationID] = icons

        case .scheduleInputTapped:
            // Navigation action - handled by Store/ContainerView
            break

        case .clearWeatherData:
            state.weatherLocations = []
            state.weathers = []
            state.weeklyWeatherIconsByLocation = [:]
            state.isLoadingWeather = false

        case .refresh:
            // Side effect handled by AppStore
            break
        }
    }

    // MARK: - Helper Functions

    /// Derive assignment status from ScheduleStatus
    /// - Parameters:
    ///   - status: The schedule status
    ///   - userName: The user name if status is OK
    /// - Returns: HomeAssignmentStatus
    public static func deriveAssignmentStatus(
        from status: ScheduleStatus,
        userName: String?
    ) -> HomeAssignmentStatus {
        switch status {
        case .ok:
            if let name = userName {
                return .confirmed(personName: name)
            } else {
                return .unconfirmed
            }
        case .ng:
            return .noAssignee
        case .notSet:
            return .unconfirmed
        }
    }

    /// Generate warnings from weekly schedule
    /// - Parameter weekSchedule: The weekly schedule
    /// - Returns: Array of warnings sorted by severity (noAssignee first)
    public static func generateWarnings(from weekSchedule: [HomeDaySchedule]) -> [HomeWarning] {
        var warnings: [HomeWarning] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E曜"

        for day in weekSchedule {
            let dayName: String
            if calendar.isDateInToday(day.date) {
                dayName = "今日"
            } else if calendar.isDateInTomorrow(day.date) {
                dayName = "明日"
            } else {
                dayName = formatter.string(from: day.date)
            }

            // Check drop-off status
            switch day.dropOff {
            case .noAssignee:
                warnings.append(HomeWarning(
                    type: .noAssignee,
                    message: "\(dayName)の送りに担当者がいません"
                ))
            case .unconfirmed:
                warnings.append(HomeWarning(
                    type: .unconfirmed,
                    message: "\(dayName)の送りが未確定です"
                ))
            case .confirmed:
                break
            }

            // Check pick-up status
            switch day.pickUp {
            case .noAssignee:
                warnings.append(HomeWarning(
                    type: .noAssignee,
                    message: "\(dayName)の迎えに担当者がいません"
                ))
            case .unconfirmed:
                warnings.append(HomeWarning(
                    type: .unconfirmed,
                    message: "\(dayName)の迎えが未確定です"
                ))
            case .confirmed:
                break
            }
        }

        // Sort warnings: noAssignee first, then unconfirmed
        return warnings.sorted { w1, w2 in
            switch (w1.type, w2.type) {
            case (.noAssignee, .unconfirmed):
                return true
            case (.unconfirmed, .noAssignee):
                return false
            default:
                return false
            }
        }
    }

    /// Derive assignment status from DayAssignment
    /// - Parameters:
    ///   - assignedUserID: The UUID of the assigned user (nil if not assigned)
    ///   - currentUserID: The current user's iCloud user ID string
    ///   - currentUserName: The current user's display name
    /// - Returns: HomeAssignmentStatus indicating whether the current user is assigned
    public static func deriveAssignmentStatusFromAssignment(
        assignedUserID: UUID?,
        currentUserID: String,
        currentUserName: String
    ) -> HomeAssignmentStatus {
        guard let assignedUserID = assignedUserID else {
            // 未割り当て
            return .unconfirmed
        }

        if assignedUserID.uuidString == currentUserID {
            // 自分が担当
            return .confirmed(personName: currentUserName)
        } else {
            // 他人が担当（自分かどうかだけ分かればいいので空文字）
            return .confirmed(personName: "")
        }
    }

    /// Calculate weather target date based on current time
    /// Before 19:00 -> today, 19:00 and after -> tomorrow
    /// - Parameter currentTime: The current time to evaluate
    /// - Returns: Today or tomorrow's date
    public static func calculateWeatherTargetDate(currentTime: Date = Date()) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)

        if hour >= 19 {
            // 19:00以降は翌日
            return calendar.date(byAdding: .day, value: 1, to: currentTime) ?? currentTime
        } else {
            // 19:00未満は当日
            return currentTime
        }
    }
}
