import Foundation
import os
import SwiftUI

private let actionLogger = Logger(subsystem: "com.tweakable.app", category: "Actions")

/// アプリ全体のStore（状態保持 + Action dispatch）
@MainActor
@Observable
public final class AppStore {
    // MARK: - State

    public private(set) var state = AppState()

    // MARK: - Dependencies

    private let networkMonitor: any NetworkMonitorProtocol
    private let weatherService: any WeatherServiceProtocol
    private let userDefaults: any UserDefaultsProtocol
    private let recipeExtractionService: any RecipeExtractionServiceProtocol

    // MARK: - Initialization

    public init(
        networkMonitor: any NetworkMonitorProtocol = NetworkMonitor(),
        weatherService: any WeatherServiceProtocol = WeatherKitService(),
        userDefaults: any UserDefaultsProtocol = UserDefaults.standard,
        recipeExtractionService: (any RecipeExtractionServiceProtocol)? = nil
    ) {
        self.networkMonitor = networkMonitor
        self.weatherService = weatherService
        self.userDefaults = userDefaults

        // RecipeExtractionService のデフォルト構成
        if let service = recipeExtractionService {
            self.recipeExtractionService = service
        } else {
            let configService = ConfigurationService()
            let htmlFetcher = HTMLFetcher()
            let openAIClient = OpenAIClient(configurationService: configService)
            self.recipeExtractionService = RecipeExtractionService(
                htmlFetcher: htmlFetcher,
                openAIClient: openAIClient,
                configurationService: configService
            )
        }
    }

    // MARK: - Public Methods

    /// アクションを送信
    public func send(_ action: AppAction) {
        actionLogger.debug("Action: \(String(describing: action))")

        // 1. Reducerで状態更新
        AppReducer.reduce(state: &state, action: action)

        // 2. 副作用の実行
        Task {
            await handleSideEffects(action)
        }
    }

    // MARK: - Side Effects

    private func handleSideEffects(_ action: AppAction) async {
        switch action {
        case .boot:
            await handleBoot()

        case .auth(let authAction):
            await handleAuthSideEffects(authAction)

        case .schedule(let scheduleAction):
            await handleScheduleSideEffects(scheduleAction)

        case .home(let homeAction):
            await handleHomeSideEffects(homeAction)

        case .sharing(let sharingAction):
            await handleSharingSideEffects(sharingAction)

        case .assignment(let assignmentAction):
            await handleAssignmentSideEffects(assignmentAction)

        case .myAssignments(let myAssignmentsAction):
            await handleMyAssignmentsSideEffects(myAssignmentsAction)

        case .recipe(let recipeAction):
            await handleRecipeSideEffects(recipeAction)

        case .setScreenState:
            // No side effects
            break
        }
    }

    /// アプリ起動時の処理
    private func handleBoot() async {
        // バックエンドなしのスタンドアロンモード
        // 認証なしで直接メイン画面へ
        send(.setScreenState(.main))
    }

    // MARK: - Auth Side Effects

    private func handleAuthSideEffects(_ action: AuthAction) async {
        // 認証機能は削除されました（バックエンドなし）
        fatalError("Auth functionality has been removed - standalone mode")
    }

    // MARK: - Schedule Side Effects

    private func handleScheduleSideEffects(_ action: ScheduleAction) async {
        switch action {
        case .setupUser, .createGroup, .loadWeekSchedule, .submitSchedule:
            // バックエンドなし - 永続化機能は削除
            fatalError("Backend functionality has been removed - standalone mode")

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    // MARK: - Home Side Effects

    private func handleHomeSideEffects(_ action: HomeAction) async {
        switch action {
        case .loadWeather:
            await loadWeatherForLocations()

        case .addWeatherLocation, .updateWeatherLocation, .removeWeatherLocation:
            // バックエンドなし - 永続化機能は削除
            break

        case .refresh:
            await loadWeatherForLocations()

        default:
            // Other actions have no side effects
            break
        }
    }

    private func loadWeatherForLocations(locations: [WeatherLocation]? = nil) async {
        let targetLocations = locations ?? state.home.weatherLocations
        let targetDate = HomeReducer.calculateWeatherTargetDate()

        guard !targetLocations.isEmpty else {
            send(.home(.weathersLoaded([])))
            return
        }

        do {
            let weathers = try await weatherService.fetchWeather(for: targetLocations, targetDate: targetDate)
            send(.home(.weathersLoaded(weathers)))

            // 週間天気アイコンも取得
            let weekDates = state.home.weekSchedule.map { $0.date }
            if !weekDates.isEmpty {
                for location in targetLocations {
                    let weeklyIcons = try await weatherService.fetchWeeklyWeatherIcons(for: location, dates: weekDates)
                    send(.home(.weeklyWeatherIconsLoaded(locationID: location.id, icons: weeklyIcons)))
                }
            }
        } catch {
            send(.home(.weatherLoadFailed(error.localizedDescription)))
        }
    }

    // MARK: - Sharing Side Effects

    private func handleSharingSideEffects(_ action: SharingAction) async {
        // グループ共有機能は削除されました（バックエンドなし）
        fatalError("Sharing functionality has been removed - standalone mode")
    }

    // MARK: - Assignment Side Effects

    private func handleAssignmentSideEffects(_ action: AssignmentAction) async {
        switch action {
        case .loadWeekAssignments, .submitAssignments:
            // バックエンドなし - 永続化機能は削除
            fatalError("Backend functionality has been removed - standalone mode")

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    // MARK: - My Assignments Side Effects

    private func handleMyAssignmentsSideEffects(_ action: MyAssignmentsAction) async {
        // バックエンドなし - 永続化機能は削除
        fatalError("Backend functionality has been removed - standalone mode")
    }

    // MARK: - Recipe Side Effects

    private func handleRecipeSideEffects(_ action: RecipeAction) async {
        switch action {
        case .loadRecipe(let url):
            do {
                let recipe = try await recipeExtractionService.extractRecipe(from: url)
                send(.recipe(.recipeLoaded(recipe)))
            } catch let error as RecipeExtractionError {
                let message: String
                switch error {
                case .htmlFetchFailed(let detail):
                    message = String(localized: "recipe_error_html_fetch_failed", bundle: .app) + ": \(detail)"
                case .apiKeyNotConfigured:
                    message = String(localized: "recipe_error_api_key_not_configured", bundle: .app)
                case .extractionFailed(let detail):
                    message = String(localized: "recipe_error_extraction_failed", bundle: .app) + ": \(detail)"
                }
                print("RecipeExtractionError: \(message)")
                send(.recipe(.recipeLoadFailed(message)))
            } catch {
                print("Unexpected error: \(error)")
                send(.recipe(.recipeLoadFailed(String(localized: "recipe_error_unexpected", bundle: .app) + ": \(error.localizedDescription)")))
            }

        case .requestSubstitution:
            // 置き換え機能は別タスク（スコープ外）
            break

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    // MARK: - Public Helpers for Onboarding

    /// オンボーディング完了処理
    public func completeOnboarding(userName: String) {
        // バックエンドなし
        fatalError("Onboarding functionality has been removed - standalone mode")
    }
}
