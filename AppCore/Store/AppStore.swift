import Foundation
import os
import SwiftUI

private let actionLogger = Logger(subsystem: "com.okumuka.app", category: "Actions")

/// アプリ全体のStore（状態保持 + Action dispatch）
@MainActor
@Observable
public final class AppStore {
    // MARK: - State

    public private(set) var state = AppState()

    // MARK: - Dependencies

    private let supabaseClient: (any SupabaseClientProtocol)?
    private let supabaseStorageService: (any SupabaseStorageServiceProtocol)?
    private let networkMonitor: any NetworkMonitorProtocol
    private let weatherService: any WeatherServiceProtocol
    private let userDefaults: any UserDefaultsProtocol

    // MARK: - Initialization

    public init(
        supabaseClient: (any SupabaseClientProtocol)? = nil,
        supabaseStorageService: (any SupabaseStorageServiceProtocol)? = nil,
        networkMonitor: any NetworkMonitorProtocol = NetworkMonitor(),
        weatherService: any WeatherServiceProtocol = WeatherKitService(),
        userDefaults: any UserDefaultsProtocol = UserDefaults.standard
    ) {
        self.supabaseClient = supabaseClient
        self.supabaseStorageService = supabaseStorageService
        self.networkMonitor = networkMonitor
        self.weatherService = weatherService
        self.userDefaults = userDefaults
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

        case .setScreenState:
            // No side effects
            break
        }
    }

    /// アプリ起動時の処理
    private func handleBoot() async {
        #if DEBUG
        // UIテストモード: 認証状態をリセットしてログイン画面を表示
        if UITestingSupport.shouldResetAuth {
            try? await supabaseClient?.logout()
            send(.auth(.sessionRestored(userID: nil)))
            return
        }
        #endif

        // 再インストール検知: UserDefaultsにフラグがなければKeychainのセッションをクリア
        let hasLaunchedKey = "hasLaunchedBefore"
        if !userDefaults.bool(forKey: hasLaunchedKey) {
            try? await supabaseClient?.logout()
            userDefaults.set(true, forKey: hasLaunchedKey)
        }

        // Supabase認証フローを開始
        send(.auth(.restoreSession))
    }

    // MARK: - Auth Side Effects

    private func handleAuthSideEffects(_ action: AuthAction) async {
        switch action {
        case .restoreSession:
            guard let client = supabaseClient else {
                send(.auth(.sessionRestored(userID: nil)))
                return
            }

            let userID = await client.restoreSession()
            send(.auth(.sessionRestored(userID: userID)))

            // 認証済みならユーザーデータをロード
            if userID != nil {
                send(.auth(.loadUserData))
            }

        case .sendOTP:
            guard let client = supabaseClient else {
                send(.auth(.errorOccurred("認証サービスが設定されていません")))
                return
            }

            let email = state.auth.email
            send(.auth(.sendingOTP))

            do {
                try await client.sendOTP(to: email)
                send(.auth(.otpSent(email: email)))
            } catch {
                send(.auth(.errorOccurred("メールの送信に失敗しました: \(error.localizedDescription)")))
            }

        case .verifyOTP:
            guard let client = supabaseClient else {
                send(.auth(.errorOccurred("認証サービスが設定されていません")))
                return
            }

            let email = state.auth.email
            let otp = state.auth.otp
            send(.auth(.verifyingOTP))

            do {
                let (userID, isNewUser) = try await client.verifyOTP(otp, email: email)
                send(.auth(.otpVerified(userID: userID, isNewUser: isNewUser)))

                // 画面遷移とデータロード
                if isNewUser {
                    // 新規ユーザー: オンボーディングへ
                    send(.setScreenState(.onboarding))
                } else {
                    // 既存ユーザー: ユーザーデータをロード
                    send(.auth(.loadUserData))
                }
            } catch {
                send(.auth(.errorOccurred("認証に失敗しました。コードを確認してください。")))
            }

        case .loadUserData:
            await loadSupabaseUserData()

        case .userDataLoaded(let profile, let groups):
            // Reducerで状態更新済み、画面遷移を行う
            if profile != nil && !groups.isEmpty {
                // プロフィールとグループがあればメイン画面へ
                send(.setScreenState(.main))

                // スケジュールと担当を初期化
                let calendar = Calendar.current
                let today = Date()
                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                    send(.schedule(.initializeWeekSchedule(weekStartDate: tomorrow)))
                    send(.assignment(.initializeWeekAssignments(weekStartDate: tomorrow)))
                }

                // 天気地点をロード
                if let groupID = state.schedule.currentGroup?.id {
                    await loadWeatherLocationsFromSupabase(groupID: groupID)
                }
            } else if profile != nil {
                // プロフィールはあるがグループがない → グループ作成画面
                send(.setScreenState(.groupSetup))
            } else {
                // プロフィールがない → オンボーディング
                send(.setScreenState(.onboarding))
            }

        case .logout:
            guard let client = supabaseClient else {
                send(.auth(.loggedOut))
                return
            }

            do {
                try await client.logout()
                send(.auth(.loggedOut))
            } catch {
                // ログアウト失敗してもローカル状態はクリア
                send(.auth(.loggedOut))
            }

        default:
            // その他のアクションは副作用なし（状態更新のみ）
            break
        }
    }

    /// Supabaseからユーザーデータ（プロフィール、グループ）をロード
    private func loadSupabaseUserData() async {
        guard let storage = supabaseStorageService,
              let userID = state.auth.authenticatedUserID else {
            send(.auth(.userDataLoaded(profile: nil, groups: [])))
            return
        }

        do {
            // プロフィールを取得
            let profile = try await storage.fetchProfile(userID: userID)

            // グループを取得
            let groups = try await storage.fetchGroupsForUser(userID: userID)

            send(.auth(.userDataLoaded(profile: profile, groups: groups)))
        } catch {
            print("[DEBUG] loadSupabaseUserData failed: \(error)")
            send(.auth(.userDataLoaded(profile: nil, groups: [])))
        }
    }

    // MARK: - Schedule Side Effects

    private func handleScheduleSideEffects(_ action: ScheduleAction) async {
        switch action {
        case .setupUser(let displayName):
            await setupUserWithSupabase(displayName: displayName)

        case .createGroup(let name):
            await createGroupWithSupabase(name: name)

        case .loadWeekSchedule(let weekStartDate):
            await loadWeekScheduleFromSupabase(weekStartDate: weekStartDate)

        case .submitSchedule:
            await submitScheduleToSupabase()

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    private func setupUserWithSupabase(displayName: String) async {
        guard let storage = supabaseStorageService,
              let userID = state.auth.authenticatedUserID else {
            send(.schedule(.errorOccurred("ユーザーが認証されていません")))
            return
        }

        do {
            let profile = Profile(id: userID, displayName: displayName)
            let savedProfile = try await storage.saveProfile(profile)

            // ProfileからUserに変換してScheduleStateを更新
            let user = User(
                id: savedProfile.id,
                iCloudUserID: "",
                displayName: savedProfile.displayName
            )
            send(.schedule(.userSetupCompleted(user)))

            // グループ作成画面へ遷移
            send(.setScreenState(.groupSetup))
        } catch {
            send(.schedule(.errorOccurred(error.localizedDescription)))
        }
    }

    private func createGroupWithSupabase(name: String) async {
        guard let storage = supabaseStorageService,
              let userID = state.auth.authenticatedUserID else {
            send(.schedule(.groupCreationFailed("ユーザーが認証されていません")))
            return
        }

        do {
            let supabaseGroup = SupabaseUserGroup(
                id: UUID(),
                name: name,
                ownerID: userID
            )
            let savedSupabaseGroup = try await storage.createGroup(supabaseGroup)

            // SupabaseUserGroupからUserGroupに変換
            let savedGroup = UserGroup(
                id: savedSupabaseGroup.id,
                name: savedSupabaseGroup.name
            )

            // ScheduleStateを更新
            send(.schedule(.groupCreated(savedGroup)))
            state.schedule.isGroupOwner = true

            // 天気データをクリア
            send(.home(.clearWeatherData))

            // スケジュールを初期化
            let calendar = Calendar.current
            let today = Date()
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                send(.schedule(.initializeWeekSchedule(weekStartDate: tomorrow)))
            }
        } catch {
            send(.schedule(.groupCreationFailed(error.localizedDescription)))
        }
    }

    private func loadWeekScheduleFromSupabase(weekStartDate: Date) async {
        guard let storage = supabaseStorageService,
              let userID = state.schedule.currentUser?.id,
              let groupID = state.schedule.currentGroup?.id else {
            send(.schedule(.setLoading(false)))
            return
        }

        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate) else {
            send(.schedule(.setLoading(false)))
            return
        }

        do {
            let entries = try await storage.fetchScheduleEntries(
                userID: userID,
                groupID: groupID,
                from: weekStartDate,
                to: endDate
            )

            if entries.isEmpty {
                send(.schedule(.initializeWeekSchedule(weekStartDate: weekStartDate)))
                send(.schedule(.setLoading(false)))
            } else {
                // SupabaseScheduleEntryからDayScheduleEntryに変換
                let dayEntries = entries.map { entry in
                    DayScheduleEntry(
                        id: entry.id,
                        date: entry.date,
                        userID: entry.userID,
                        userGroupID: entry.groupID,
                        dropOffStatus: ScheduleStatus(from: entry.dropOffStatus),
                        pickUpStatus: ScheduleStatus(from: entry.pickUpStatus)
                    )
                }
                send(.schedule(.weekScheduleLoaded(dayEntries)))
            }
        } catch {
            print("Failed to load schedule: \(error)")
            send(.schedule(.initializeWeekSchedule(weekStartDate: weekStartDate)))
            send(.schedule(.setLoading(false)))
        }
    }

    private func submitScheduleToSupabase() async {
        guard let storage = supabaseStorageService,
              state.schedule.currentUser != nil,
              let groupID = state.schedule.currentGroup?.id else {
            send(.schedule(.errorOccurred("グループが設定されていません")))
            send(.schedule(.setSaving(false)))
            return
        }

        do {
            // DayScheduleEntryからSupabaseScheduleEntryに変換
            let supabaseEntries = state.schedule.weekEntries.map { entry in
                SupabaseScheduleEntry(
                    id: entry.id,
                    userID: entry.userID,
                    groupID: groupID,
                    date: entry.date,
                    dropOffStatus: entry.dropOffStatus.toSupabase,
                    pickUpStatus: entry.pickUpStatus.toSupabase
                )
            }

            let savedEntries = try await storage.saveScheduleEntries(supabaseEntries)

            // 保存されたエントリをDayScheduleEntryに変換
            let dayEntries = savedEntries.map { entry in
                DayScheduleEntry(
                    id: entry.id,
                    date: entry.date,
                    userID: entry.userID,
                    userGroupID: entry.groupID,
                    dropOffStatus: ScheduleStatus(from: entry.dropOffStatus),
                    pickUpStatus: ScheduleStatus(from: entry.pickUpStatus)
                )
            }

            send(.schedule(.submitCompleted(dayEntries)))
            send(.schedule(.showSuccessToast))

            // 5秒後にトーストを非表示
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            send(.schedule(.hideSuccessToast))
        } catch {
            send(.schedule(.errorOccurred(error.localizedDescription)))
        }
    }

    // MARK: - Home Side Effects

    private func handleHomeSideEffects(_ action: HomeAction) async {
        switch action {
        case .loadWeather:
            await loadWeatherForLocations()

        case .addWeatherLocation(let location):
            await saveWeatherLocationToSupabase(location)

        case .updateWeatherLocation(let location):
            await saveWeatherLocationToSupabase(location)

        case .removeWeatherLocation(let locationID):
            await deleteWeatherLocationFromSupabase(locationID)

        case .refresh:
            // Refresh all home screen data
            let calendar = Calendar.current
            let today = Date()
            let weekStartDate = calendar.startOfDay(for: today)
            await loadWeekAssignmentsFromSupabase(weekStartDate: weekStartDate)

            if let groupID = state.schedule.currentGroup?.id {
                await loadWeatherLocationsFromSupabase(groupID: groupID)
            }

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

    private func loadWeatherLocationsFromSupabase(groupID: UUID) async {
        guard let storage = supabaseStorageService else { return }

        do {
            let supabaseLocations = try await storage.fetchWeatherLocations(groupID: groupID)
            let locations = supabaseLocations.map { loc in
                // SupabaseWeatherLocationのnameをlabelとplaceNameの両方に使う
                WeatherLocation(
                    id: loc.id,
                    label: loc.name,
                    latitude: loc.latitude,
                    longitude: loc.longitude,
                    placeName: loc.name,
                    userGroupID: loc.groupID
                )
            }
            send(.home(.setWeatherLocations(locations)))
            if !locations.isEmpty {
                await loadWeatherForLocations(locations: locations)
            }
        } catch {
            print("[DEBUG] loadWeatherLocationsFromSupabase: Failed - \(error)")
        }
    }

    private func saveWeatherLocationToSupabase(_ location: WeatherLocation) async {
        guard let storage = supabaseStorageService else { return }

        do {
            // WeatherLocationのlabelをnameとして保存
            let supabaseLocation = SupabaseWeatherLocation(
                id: location.id,
                groupID: location.userGroupID,
                name: location.label,
                latitude: location.latitude,
                longitude: location.longitude
            )
            _ = try await storage.saveWeatherLocation(supabaseLocation)
            await loadWeatherForLocations()
        } catch {
            print("Failed to save weather location: \(error)")
        }
    }

    private func deleteWeatherLocationFromSupabase(_ locationID: UUID) async {
        guard let storage = supabaseStorageService else { return }

        do {
            try await storage.deleteWeatherLocation(locationID: locationID)
        } catch {
            print("Failed to delete weather location: \(error)")
        }
    }

    // MARK: - Sharing Side Effects

    private func handleSharingSideEffects(_ action: SharingAction) async {
        switch action {
        case .startCreatingInviteCode:
            await createInviteCode()

        case .startJoiningWithCode:
            await joinWithInviteCode()

        case .loadMembers:
            await loadMembersFromSupabase()

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    /// 招待コードを作成（オーナー用）
    private func createInviteCode() async {
        guard let storage = supabaseStorageService else {
            send(.sharing(.inviteCodeCreationFailed(error: "Supabaseサービスが設定されていません")))
            return
        }

        guard let group = state.schedule.currentGroup else {
            send(.sharing(.inviteCodeCreationFailed(error: "グループが見つかりません")))
            return
        }

        guard let currentUser = state.schedule.currentUser else {
            send(.sharing(.inviteCodeCreationFailed(error: "ユーザーが見つかりません")))
            return
        }

        do {
            let inviteCode = try await storage.createInviteCode(
                groupID: group.id,
                createdBy: currentUser.id
            )
            send(.sharing(.inviteCodeCreated(code: inviteCode.code)))
        } catch {
            send(.sharing(.inviteCodeCreationFailed(error: error.localizedDescription)))
        }
    }

    /// 招待コードで参加（参加者用）
    private func joinWithInviteCode() async {
        guard let storage = supabaseStorageService else {
            send(.sharing(.joinWithCodeFailed(error: "Supabaseサービスが設定されていません")))
            return
        }

        let code = state.sharing.inviteCodeInput
        guard !code.isEmpty else {
            send(.sharing(.joinWithCodeFailed(error: "招待コードを入力してください")))
            return
        }

        guard let currentUser = state.schedule.currentUser else {
            send(.sharing(.joinWithCodeFailed(error: "ユーザーが見つかりません")))
            return
        }

        do {
            // 招待コードを検証
            guard let inviteCode = try await storage.fetchInviteCode(code: code) else {
                send(.sharing(.joinWithCodeFailed(error: "無効な招待コードです")))
                return
            }

            // 招待コードを使用済みにする
            _ = try await storage.useInviteCode(code: code, usedBy: currentUser.id)

            // グループを取得
            guard let supabaseGroup = try await storage.fetchGroup(groupID: inviteCode.groupID) else {
                send(.sharing(.joinWithCodeFailed(error: "グループが見つかりません")))
                return
            }

            // グループにメンバーとして追加
            _ = try await storage.addMemberApproved(userID: currentUser.id, groupID: supabaseGroup.id)

            send(.sharing(.joinedWithCode(group: supabaseGroup)))
        } catch {
            send(.sharing(.joinWithCodeFailed(error: error.localizedDescription)))
        }
    }

    private func loadMembersFromSupabase() async {
        send(.sharing(.startLoadingMembers))

        guard let storage = supabaseStorageService,
              let groupID = state.schedule.currentGroup?.id else {
            send(.sharing(.setMembers([])))
            return
        }

        do {
            // グループ情報を取得してオーナーIDを確認
            let group = try await storage.fetchGroup(groupID: groupID)
            let ownerID = group?.ownerID

            let memberships = try await storage.fetchGroupMemberships(groupID: groupID)
            var members: [GroupMember] = []

            for membership in memberships {
                if let profile = try await storage.fetchProfile(userID: membership.userID) {
                    let member = GroupMember(
                        participantID: membership.userID.uuidString,
                        displayName: profile.displayName,
                        isOwner: membership.userID == ownerID
                    )
                    members.append(member)
                }
            }

            // オーナーを先頭に並べる
            members.sort { $0.isOwner && !$1.isOwner }

            send(.sharing(.setMembers(members)))
        } catch {
            send(.sharing(.loadMembersFailed(error: error.localizedDescription)))
        }
    }

    // MARK: - Assignment Side Effects

    private func handleAssignmentSideEffects(_ action: AssignmentAction) async {
        switch action {
        case .loadWeekAssignments(let weekStartDate):
            await loadWeekAssignmentsFromSupabase(weekStartDate: weekStartDate)

        case .submitAssignments:
            await saveAssignmentsToSupabase()

        default:
            // その他のアクションは副作用なし
            break
        }
    }

    private func loadWeekAssignmentsFromSupabase(weekStartDate: Date) async {
        send(.assignment(.setLoading(true)))

        guard let storage = supabaseStorageService,
              let groupID = state.schedule.currentGroup?.id else {
            send(.assignment(.initializeWeekAssignments(weekStartDate: weekStartDate)))
            send(.assignment(.setLoading(false)))
            return
        }

        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate) else {
            send(.assignment(.setLoading(false)))
            return
        }

        do {
            let supabaseAssignments = try await storage.fetchDayAssignments(
                groupID: groupID,
                from: weekStartDate,
                to: endDate
            )

            if supabaseAssignments.isEmpty {
                send(.assignment(.initializeWeekAssignments(weekStartDate: weekStartDate)))
            } else {
                let assignments = supabaseAssignments.map { a in
                    DayAssignment(
                        id: a.id,
                        date: a.date,
                        userGroupID: a.groupID,
                        assignedDropOffUserID: a.dropOffUserID,
                        assignedPickUpUserID: a.pickUpUserID
                    )
                }
                send(.assignment(.weekAssignmentsLoaded(assignments)))
            }
            send(.assignment(.setLoading(false)))
        } catch {
            send(.assignment(.initializeWeekAssignments(weekStartDate: weekStartDate)))
            send(.assignment(.setLoading(false)))
        }
    }

    private func saveAssignmentsToSupabase() async {
        guard state.schedule.isGroupOwner else {
            send(.assignment(.errorOccurred("オーナーのみが担当を設定できます")))
            return
        }

        guard let storage = supabaseStorageService,
              let groupID = state.schedule.currentGroup?.id else {
            send(.assignment(.errorOccurred("グループが見つかりません")))
            return
        }

        send(.assignment(.setSaving(true)))

        let assignments = state.assignment.weekAssignments

        do {
            let supabaseAssignments = assignments.map { a in
                SupabaseDayAssignment(
                    id: a.id,
                    groupID: groupID,
                    date: a.date,
                    dropOffUserID: a.assignedDropOffUserID,
                    pickUpUserID: a.assignedPickUpUserID
                )
            }

            let savedAssignments = try await storage.saveDayAssignments(supabaseAssignments)

            let dayAssignments = savedAssignments.map { a in
                DayAssignment(
                    id: a.id,
                    date: a.date,
                    userGroupID: a.groupID,
                    assignedDropOffUserID: a.dropOffUserID,
                    assignedPickUpUserID: a.pickUpUserID
                )
            }

            send(.assignment(.submitCompleted(dayAssignments)))
        } catch {
            send(.assignment(.errorOccurred(error.localizedDescription)))
        }

        send(.assignment(.setSaving(false)))
    }

    // MARK: - My Assignments Side Effects

    private func handleMyAssignmentsSideEffects(_ action: MyAssignmentsAction) async {
        switch action {
        case .loadMyAssignments:
            await loadMyAssignmentsFromSupabase()
        default:
            break
        }
    }

    private func loadMyAssignmentsFromSupabase() async {
        guard let storage = supabaseStorageService,
              let currentUser = state.schedule.currentUser else {
            send(.myAssignments(.errorOccurred("ユーザーが見つかりません")))
            return
        }

        let groups = state.schedule.groups
        let today = Date()
        let calendar = Calendar.current

        guard let endDate = calendar.date(byAdding: .day, value: 13, to: today) else {
            send(.myAssignments(.errorOccurred("日付計算に失敗しました")))
            return
        }

        var allAssignments: [(groupID: UUID, groupName: String, assignment: DayAssignment)] = []

        for group in groups {
            do {
                let supabaseAssignments = try await storage.fetchDayAssignments(
                    groupID: group.id,
                    from: today,
                    to: endDate
                )

                for a in supabaseAssignments {
                    let assignment = DayAssignment(
                        id: a.id,
                        date: a.date,
                        userGroupID: a.groupID,
                        assignedDropOffUserID: a.dropOffUserID,
                        assignedPickUpUserID: a.pickUpUserID
                    )
                    allAssignments.append((
                        groupID: group.id,
                        groupName: group.name,
                        assignment: assignment
                    ))
                }
            } catch {
                print("[DEBUG] loadMyAssignmentsFromSupabase: Failed for group '\(group.name)': \(error)")
            }
        }

        let myItems = MyAssignmentsReducer.filterMyAssignments(
            assignments: allAssignments,
            userID: currentUser.id,
            today: today
        )

        send(.myAssignments(.myAssignmentsLoaded(myItems)))
    }

    // MARK: - Public Helpers for Onboarding

    /// オンボーディング完了処理
    public func completeOnboarding(userName: String) {
        send(.schedule(.setupUser(displayName: userName)))
    }

    // MARK: - Legacy URL Invitation Support

    /// 招待URLから招待情報を取得（Supabase版ではURL招待は未サポート）
    /// 招待コード方式に移行したため、常にエラーをスローする
    public func fetchInvitationInfo(from url: URL) async throws -> InvitationInfo {
        throw SupabaseStorageError.unknown("招待URLは現在サポートされていません。招待コードを使用してください。")
    }
}
