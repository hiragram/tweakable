import MapKit
import Prefire
import SwiftUI

/// Weather location edit view (parameter-based, no @State)
struct WeatherLocationEditView: View {
    // MARK: - Accessibility IDs

    public enum AccessibilityID: AccessibilityIDConvertible, Sendable {
        case cancelButton
        case saveButton
        case mapSelector
        case labelTextField
        case clearLabelButton
        case deleteButton

        public var rawIdentifier: String {
            switch self {
            case .cancelButton:
                return "weatherLocationEdit_button_cancel"
            case .saveButton:
                return "weatherLocationEdit_button_save"
            case .mapSelector:
                return "weatherLocationEdit_map_selector"
            case .labelTextField:
                return "weatherLocationEdit_textField_label"
            case .clearLabelButton:
                return "weatherLocationEdit_button_clearLabel"
            case .deleteButton:
                return "weatherLocationEdit_button_delete"
            }
        }
    }

    // MARK: - Parameters

    /// Editing mode
    let mode: Mode

    /// Current map region
    let region: MKCoordinateRegion

    /// Selected coordinate (nil if not selected)
    let selectedCoordinate: CLLocationCoordinate2D?

    /// Label text
    let label: String

    /// Place name from reverse geocoding
    let placeName: String

    /// Whether save button should be enabled
    let canSave: Bool

    /// Whether loading (geocoding)
    let isLoading: Bool

    // MARK: - Actions

    let onRegionChanged: (MKCoordinateRegion) -> Void
    let onMapTapped: (CLLocationCoordinate2D) -> Void
    let onLabelChanged: (String) -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    // MARK: - Private

    private let theme = DesignSystem.default

    // MARK: - Mode

    enum Mode: Equatable {
        case add
        case edit(WeatherLocation)

        var title: String {
            switch self {
            case .add:
                return String(localized: "location_add_title", bundle: .app)
            case .edit:
                return String(localized: "location_edit_title", bundle: .app)
            }
        }

        var showDelete: Bool {
            switch self {
            case .add:
                return false
            case .edit:
                return true
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                theme.colors.backgroundPrimary.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: theme.spacing.lg) {
                        mapSection

                        formSection

                        if mode.showDelete {
                            deleteSection
                        }

                        Spacer()
                            .frame(height: theme.spacing.xl)
                    }
                    .padding(.horizontal, theme.spacing.md)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common_cancel", bundle: .app)) {
                        onDismiss()
                    }
                    .foregroundColor(theme.colors.primaryBrand.color)
                    .accessibilityIdentifier(AccessibilityID.cancelButton)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common_save", bundle: .app)) {
                        onSave()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(canSave ? theme.colors.primaryBrand.color : theme.colors.textTertiary.color)
                    .disabled(!canSave)
                    .accessibilityIdentifier(AccessibilityID.saveButton)
                }
            }
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("location_select_from_map", bundle: .app)
                .font(theme.typography.headlineSmall.font)
                .foregroundColor(theme.colors.textSecondary.color)

            ZStack {
                MapReader { proxy in
                    Map(initialPosition: .region(region)) {
                        if let coordinate = selectedCoordinate {
                            Marker("", coordinate: coordinate)
                                .tint(theme.colors.primaryBrand.color)
                        }
                    }
                    .mapStyle(.standard)
                    .onTapGesture { screenLocation in
                        if let coordinate = proxy.convert(screenLocation, from: .local) {
                            onMapTapped(coordinate)
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.mapSelector)
                }

                // Tap instruction overlay
                if selectedCoordinate == nil {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("location_tap_to_select", bundle: .app)
                                .font(theme.typography.bodyMedium.font)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding(.bottom, theme.spacing.md)
                    }
                    .allowsHitTesting(false)
                }

                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                    .allowsHitTesting(false)
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                    .stroke(theme.colors.border.color, lineWidth: 1)
            )
        }
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: theme.spacing.lg) {
            // Label input
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text("location_label", bundle: .app)
                    .font(theme.typography.headlineSmall.font)
                    .foregroundColor(theme.colors.textSecondary.color)

                HStack {
                    TextField(String(localized: "location_label_placeholder", bundle: .app), text: Binding(
                        get: { label },
                        set: { onLabelChanged($0) }
                    ))
                    .font(theme.typography.bodyLarge.font)
                    .accessibilityIdentifier(AccessibilityID.labelTextField)

                    if !label.isEmpty {
                        Button {
                            onLabelChanged("")
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(theme.colors.textTertiary.color)
                        }
                        .accessibilityIdentifier(AccessibilityID.clearLabelButton)
                    }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.backgroundSecondary.color)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))

                Text("location_label_helper", bundle: .app)
                    .font(theme.typography.captionLarge.font)
                    .foregroundColor(theme.colors.textTertiary.color)
            }

            // Place name (read only)
            if !placeName.isEmpty || selectedCoordinate != nil {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("location_address", bundle: .app)
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textSecondary.color)

                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.colors.primaryBrand.color)

                        if placeName.isEmpty {
                            Text("location_fetching_address", bundle: .app)
                                .font(theme.typography.bodyMedium.font)
                                .foregroundColor(theme.colors.textTertiary.color)
                        } else {
                            Text(placeName)
                                .font(theme.typography.bodyMedium.font)
                                .foregroundColor(theme.colors.textPrimary.color)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .background(theme.colors.backgroundSecondary.color)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.md))
                }
            }
        }
    }

    // MARK: - Delete Section

    private var deleteSection: some View {
        VStack(spacing: theme.spacing.md) {
            Divider()
                .background(theme.colors.separator.color)

            Button {
                onDelete()
            } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                    Text("location_delete", bundle: .app)
                        .font(theme.typography.bodyMedium.font)
                }
                .foregroundColor(theme.colors.error.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                        .fill(theme.colors.error.color.opacity(0.1))
                )
            }
            .accessibilityIdentifier(AccessibilityID.deleteButton)
        }
        .padding(.top, theme.spacing.md)
    }
}

// MARK: - Preview

#Preview("WeatherLocationEditView - Add") {
    WeatherLocationEditView(
        mode: .add,
        region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ),
        selectedCoordinate: nil,
        label: "",
        placeName: "",
        canSave: false,
        isLoading: false,
        onRegionChanged: { _ in },
        onMapTapped: { _ in },
        onLabelChanged: { _ in },
        onSave: {},
        onDelete: {},
        onDismiss: {}
    )
}

#Preview("WeatherLocationEditView - Selected") {
    WeatherLocationEditView(
        mode: .add,
        region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ),
        selectedCoordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        label: "家",
        placeName: "東京都渋谷区神南1丁目",
        canSave: true,
        isLoading: false,
        onRegionChanged: { _ in },
        onMapTapped: { _ in },
        onLabelChanged: { _ in },
        onSave: {},
        onDelete: {},
        onDismiss: {}
    )
}

#Preview("WeatherLocationEditView - Edit") {
    let location = WeatherLocation(
        label: "家",
        latitude: 35.6762,
        longitude: 139.6503,
        placeName: "東京都渋谷区神南1丁目",
        userGroupID: UUID()
    )

    return WeatherLocationEditView(
        mode: .edit(location),
        region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ),
        selectedCoordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        label: "家",
        placeName: "東京都渋谷区神南1丁目",
        canSave: true,
        isLoading: false,
        onRegionChanged: { _ in },
        onMapTapped: { _ in },
        onLabelChanged: { _ in },
        onSave: {},
        onDelete: {},
        onDismiss: {}
    )
}

#Preview("WeatherLocationEditView - Loading") {
    WeatherLocationEditView(
        mode: .add,
        region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ),
        selectedCoordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        label: "",
        placeName: "",
        canSave: false,
        isLoading: true,
        onRegionChanged: { _ in },
        onMapTapped: { _ in },
        onLabelChanged: { _ in },
        onSave: {},
        onDelete: {},
        onDismiss: {}
    )
}


