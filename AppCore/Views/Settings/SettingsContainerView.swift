import SwiftUI
@preconcurrency import MapKit
import CoreLocation

/// Container view that connects AppStore to SettingsView
struct SettingsContainerView: View {
    let store: AppStore
    let onDismiss: () -> Void

    // MARK: - Local State

    @State private var showsMyAssignments = false
    @State private var showsAddLocation = false
    @State private var editingLocation: WeatherLocation?
    @State private var showsMemberList = false
    @State private var showsJoinWithCode = false
    @State private var showsAbout = false
    @State private var pendingInvitationInfo: InvitationInfo?

    // MARK: - Computed Properties

    /// オーナーかどうか（ScheduleStateから取得）
    private var isGroupOwner: Bool {
        store.state.schedule.isGroupOwner
    }

    // MARK: - Body

    var body: some View {
        SettingsView(
            weatherLocations: store.state.home.weatherLocations,
            canAddLocation: store.state.home.weatherLocations.count < 2,
            pendingJoinRequestsCount: store.state.sharing.pendingJoinRequests.count,
            isGroupOwner: isGroupOwner,
            onMyAssignmentsTapped: {
                showsMyAssignments = true
            },
            onAddLocationTapped: {
                showsAddLocation = true
            },
            onEditLocation: { location in
                editingLocation = location
            },
            onDeleteLocation: { location in
                store.send(.home(.removeWeatherLocation(location.id)))
            },
            onMemberListTapped: {
                showsMemberList = true
            },
            onJoinWithCodeTapped: {
                showsJoinWithCode = true
            },
            onAboutTapped: {
                showsAbout = true
            },
            onPasteInvitationURL: { url in
                // 招待情報を取得してシートを表示（設定画面内で表示）
                Task { @MainActor in
                    do {
                        let info = try await store.fetchInvitationInfo(from: url)
                        // acceptInvitationStateを.pendingに設定
                        store.send(.sharing(.setInvitationInfo(info)))
                        pendingInvitationInfo = info
                    } catch {
                        store.send(.sharing(.shareAcceptanceFailed(error: error.localizedDescription)))
                    }
                }
            },
            onDismiss: onDismiss,
            groupSettingsDestination: {
                GroupSettingsContainerView(store: store)
            }
        )
        .sheet(isPresented: $showsMyAssignments) {
            MyAssignmentsContainerView(
                store: store,
                onDismiss: {
                    showsMyAssignments = false
                }
            )
        }
        .sheet(isPresented: $showsAddLocation) {
            WeatherLocationEditContainerView(
                store: store,
                mode: .add,
                onDismiss: {
                    showsAddLocation = false
                }
            )
        }
        .sheet(item: $editingLocation) { location in
            WeatherLocationEditContainerView(
                store: store,
                mode: .edit(location),
                onDismiss: {
                    editingLocation = nil
                }
            )
        }
        .sheet(isPresented: $showsMemberList) {
            MemberListContainerView(
                store: store,
                onDismiss: {
                    showsMemberList = false
                }
            )
        }
        .sheet(isPresented: $showsJoinWithCode) {
            JoinWithCodeContainerView(
                store: store,
                onDismiss: {
                    showsJoinWithCode = false
                }
            )
        }
        .sheet(isPresented: $showsAbout) {
            AboutContainerView(
                onDismiss: {
                    showsAbout = false
                }
            )
        }
        .sheet(item: $pendingInvitationInfo) { info in
            AcceptInvitationContainerView(
                store: store,
                invitationInfo: info,
                onDismiss: {
                    pendingInvitationInfo = nil
                },
                onContinueToSchedule: {
                    pendingInvitationInfo = nil
                    // 参加完了後は設定画面も閉じてメイン画面へ
                    onDismiss()
                }
            )
        }
        .onChange(of: store.state.schedule.currentGroup) { _, newGroup in
            // グループが削除されて nil になった場合、設定画面を閉じる
            if newGroup == nil {
                onDismiss()
            }
        }
    }
}

/// Container view for WeatherLocationEditView
struct WeatherLocationEditContainerView: View {
    let store: AppStore
    let mode: WeatherLocationEditView.Mode
    let onDismiss: () -> Void

    // MARK: - Local State

    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var label: String
    @State private var placeName: String = ""
    @State private var isLoading: Bool = false

    // MARK: - Initialization

    init(store: AppStore, mode: WeatherLocationEditView.Mode, onDismiss: @escaping () -> Void) {
        self.store = store
        self.mode = mode
        self.onDismiss = onDismiss

        // Initialize state based on mode
        switch mode {
        case .add:
            // Default to Tokyo
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            _selectedCoordinate = State(initialValue: nil)
            _label = State(initialValue: "")
            _placeName = State(initialValue: "")
        case .edit(let location):
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
            _selectedCoordinate = State(initialValue: coordinate)
            _label = State(initialValue: location.label)
            _placeName = State(initialValue: location.placeName)
        }
    }

    // MARK: - Computed Properties

    private var canSave: Bool {
        selectedCoordinate != nil && !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var userGroupID: UUID? {
        store.state.schedule.currentGroup?.id
    }

    // MARK: - Body

    var body: some View {
        WeatherLocationEditView(
            mode: mode,
            region: region,
            selectedCoordinate: selectedCoordinate,
            label: label,
            placeName: placeName,
            canSave: canSave,
            isLoading: isLoading,
            onRegionChanged: { newRegion in
                region = newRegion
            },
            onMapTapped: { coordinate in
                selectedCoordinate = coordinate
                reverseGeocode(coordinate: coordinate)
            },
            onLabelChanged: { newLabel in
                label = newLabel
            },
            onSave: {
                saveLocation()
            },
            onDelete: {
                deleteLocation()
            },
            onDismiss: onDismiss
        )
    }

    // MARK: - Actions

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        isLoading = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        Task {
            defer { isLoading = false }

            guard let request = MKReverseGeocodingRequest(location: location) else {
                placeName = "住所を取得できませんでした"
                return
            }

            do {
                let mapItems = try await request.mapItems
                if let mapItem = mapItems.first, let address = mapItem.address {
                    // shortAddressはOptional、fullAddressは非Optional
                    if let shortAddress = address.shortAddress, !shortAddress.isEmpty {
                        placeName = shortAddress
                    } else if !address.fullAddress.isEmpty {
                        placeName = address.fullAddress
                    } else {
                        placeName = "住所を取得できませんでした"
                    }
                } else {
                    placeName = "住所を取得できませんでした"
                }
            } catch {
                placeName = "住所を取得できませんでした"
            }
        }
    }

    private func saveLocation() {
        guard let coordinate = selectedCoordinate,
              let groupID = userGroupID else { return }

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .add:
            let newLocation = WeatherLocation(
                label: trimmedLabel,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                placeName: placeName,
                userGroupID: groupID
            )
            store.send(.home(.addWeatherLocation(newLocation)))

        case .edit(let existingLocation):
            var updatedLocation = existingLocation
            updatedLocation.label = trimmedLabel
            updatedLocation.latitude = coordinate.latitude
            updatedLocation.longitude = coordinate.longitude
            updatedLocation.placeName = placeName
            store.send(.home(.updateWeatherLocation(updatedLocation)))
        }

        onDismiss()
    }

    private func deleteLocation() {
        if case .edit(let location) = mode {
            store.send(.home(.removeWeatherLocation(location.id)))
        }
        onDismiss()
    }
}

// MARK: - Preview

#Preview("Settings Container") {
    // Note: Requires mock store with proper initialization
    // Use SettingsView preview instead for isolated testing
    Text("Preview requires AppStore setup")
}
