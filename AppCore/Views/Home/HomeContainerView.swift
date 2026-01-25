import SwiftUI

/// Container view that connects AppStore to HomeView
struct HomeContainerView: View {
    let store: AppStore

    /// State for showing create group sheet
    @State private var showsCreateGroupSheet = false

    /// State for showing settings sheet
    @State private var showsSettingsSheet = false

    /// State for showing schedule input sheet
    @State private var showsScheduleInputSheet = false

    /// State for showing assignment picker sheet
    @State private var showsAssignmentPickerSheet = false

    /// Whether the user has a group set up
    private var hasGroup: Bool {
        store.state.schedule.currentGroup != nil
    }

    /// Whether the user is an approved member of the group
    private var isApprovedMember: Bool {
        store.state.sharing.isApprovedMember
    }

    /// Whether the current user is the group owner
    private var isOwner: Bool {
        store.state.schedule.isGroupOwner
    }

    var body: some View {
        Group {
            if hasGroup {
                if isApprovedMember {
                    homeViewContent
                } else {
                    waitingForApprovalContent
                }
            } else {
                noGroupContent
            }
        }
        .sheet(isPresented: $showsCreateGroupSheet) {
            CreateGroupContainerView(
                store: store,
                onCancel: {
                    showsCreateGroupSheet = false
                },
                onComplete: {
                    showsCreateGroupSheet = false
                },
                onJoinComplete: {
                    // 招待参加完了後はシートを閉じる
                    showsCreateGroupSheet = false
                }
            )
        }
        .sheet(isPresented: $showsSettingsSheet) {
            SettingsContainerView(
                store: store,
                onDismiss: {
                    showsSettingsSheet = false
                    // 天気データをリロード
                    loadWeather()
                }
            )
        }
        .sheet(isPresented: $showsScheduleInputSheet) {
            NavigationStack {
                ScheduleContainerView(
                    store: store,
                    onSubmitCompleted: {
                        showsScheduleInputSheet = false
                    }
                )
                .navigationTitle("予定入力")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("閉じる") {
                            showsScheduleInputSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showsAssignmentPickerSheet) {
            NavigationStack {
                AssignmentPickerContainerView(
                    store: store,
                    onDismiss: {
                        showsAssignmentPickerSheet = false
                    }
                )
            }
        }
    }

    // MARK: - Content Views

    private var homeViewContent: some View {
        HomeView_Okumuka(
            groupName: store.state.schedule.currentGroup?.name ?? "",
            groups: store.state.schedule.groups,
            todayDropOff: store.state.home.todayDropOff,
            todayPickUp: store.state.home.todayPickUp,
            weatherLocations: store.state.home.weatherLocations,
            weathers: store.state.home.weathers,
            weatherTargetDate: weatherTargetDate,
            weekSchedule: store.state.home.weekSchedule,
            weeklyWeatherByLocation: weeklyWeatherByLocation,
            warnings: computedWarnings,
            currentUserName: store.state.home.currentUserName,
            isLoadingWeather: store.state.home.isLoadingWeather,
            isOwner: isOwner,
            onScheduleInputTapped: {
                store.send(.home(.scheduleInputTapped))
                showsScheduleInputSheet = true
            },
            onSettingsTapped: {
                showsSettingsSheet = true
            },
            onDecideAssigneeTapped: {
                showsAssignmentPickerSheet = true
            },
            onGroupSelected: { groupID in
                store.send(.schedule(.selectGroup(groupID)))
            },
            onCreateGroupTapped: {
                showsCreateGroupSheet = true
            },
            onRefresh: {
                store.send(.home(.refresh))
            }
        )
        .onAppear {
            syncHomeStateFromAssignment()
            loadWeather()
        }
        .onChange(of: store.state.assignment.weekAssignments) { _, _ in
            // weekAssignmentsが更新されたらHomeStateを同期
            syncHomeStateFromAssignment()
        }
    }

    /// Weather target date based on current time
    private var weatherTargetDate: Date? {
        guard !store.state.home.weatherLocations.isEmpty else { return nil }
        return HomeReducer.calculateWeatherTargetDate()
    }

    private var noGroupContent: some View {
        NoGroupView_Okumuka(
            onCreateGroupTapped: {
                showsCreateGroupSheet = true
            }
        )
    }

    private var waitingForApprovalContent: some View {
        WaitingForApprovalView_Okumuka(
            groupName: store.state.schedule.currentGroup?.name ?? "",
            isLoading: store.state.sharing.isCheckingApprovalStatus,
            onReload: {
                store.send(.sharing(.checkApprovalStatus))
            }
        )
    }

    // MARK: - Computed Properties

    /// Warnings computed from the current week schedule
    private var computedWarnings: [HomeWarning] {
        HomeReducer.generateWarnings(from: store.state.home.weekSchedule)
    }

    /// Weekly weather icons organized by location
    private var weeklyWeatherByLocation: [(location: WeatherLocation, icons: [Date: String])] {
        store.state.home.weatherLocations.compactMap { location in
            guard let icons = store.state.home.weeklyWeatherIconsByLocation[location.id] else {
                return nil
            }
            return (location: location, icons: icons)
        }
    }

    // MARK: - Data Sync

    /// Sync home state from assignment state when the view appears
    private func syncHomeStateFromAssignment() {
        let scheduleState = store.state.schedule
        let assignmentState = store.state.assignment
        let currentUserID = scheduleState.currentUser?.iCloudUserID ?? ""
        let userName = scheduleState.currentUser?.displayName ?? ""

        // Update current user name
        store.send(.home(.updateCurrentUserName(userName)))

        // Convert week assignments to home day schedules
        let homeDaySchedules = assignmentState.weekAssignments.map { assignment -> HomeDaySchedule in
            HomeDaySchedule(
                date: assignment.date,
                dropOff: HomeReducer.deriveAssignmentStatusFromAssignment(
                    assignedUserID: assignment.assignedDropOffUserID,
                    currentUserID: currentUserID,
                    currentUserName: userName
                ),
                pickUp: HomeReducer.deriveAssignmentStatusFromAssignment(
                    assignedUserID: assignment.assignedPickUpUserID,
                    currentUserID: currentUserID,
                    currentUserName: userName
                )
            )
        }

        store.send(.home(.updateWeekSchedule(homeDaySchedules)))

        // Update today's schedule
        if let todayAssignment = assignmentState.weekAssignments.first(where: { Calendar.current.isDateInToday($0.date) }) {
            store.send(.home(.updateTodaySchedule(
                dropOff: HomeReducer.deriveAssignmentStatusFromAssignment(
                    assignedUserID: todayAssignment.assignedDropOffUserID,
                    currentUserID: currentUserID,
                    currentUserName: userName
                ),
                pickUp: HomeReducer.deriveAssignmentStatusFromAssignment(
                    assignedUserID: todayAssignment.assignedPickUpUserID,
                    currentUserID: currentUserID,
                    currentUserName: userName
                )
            )))
        }
    }

    /// Load weather data from WeatherKit
    private func loadWeather() {
        store.send(.home(.loadWeather))
    }
}

// MARK: - Preview

// Preview requires mock dependencies, so use HomeView preview instead
