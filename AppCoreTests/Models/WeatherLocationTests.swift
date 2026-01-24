import Testing
import Foundation
@testable import AppCore

@Suite
struct WeatherLocationTests {

    // MARK: - Initialization Tests

    @Test
    func weatherLocation_init_setsAllProperties() {
        let id = UUID()
        let userGroupID = UUID()
        let location = WeatherLocation(
            id: id,
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )

        #expect(location.id == id)
        #expect(location.label == "家")
        #expect(location.latitude == 35.6762)
        #expect(location.longitude == 139.6503)
        #expect(location.placeName == "東京都渋谷区")
        #expect(location.userGroupID == userGroupID)
    }

    @Test
    func weatherLocation_init_generatesUniqueIdByDefault() {
        let userGroupID = UUID()
        let location1 = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )
        let location2 = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )

        #expect(location1.id != location2.id)
    }

    // MARK: - Identifiable Tests

    @Test
    func weatherLocation_conformsToIdentifiable() {
        let id = UUID()
        let location = WeatherLocation(
            id: id,
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )
        #expect(location.id == id)
    }

    // MARK: - Mutability Tests

    @Test
    func weatherLocation_label_isMutable() {
        var location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )
        location.label = "保育園"
        #expect(location.label == "保育園")
    }

    @Test
    func weatherLocation_latitude_isMutable() {
        var location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )
        location.latitude = 35.6812
        #expect(location.latitude == 35.6812)
    }

    @Test
    func weatherLocation_longitude_isMutable() {
        var location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )
        location.longitude = 139.7671
        #expect(location.longitude == 139.7671)
    }

    @Test
    func weatherLocation_placeName_isMutable() {
        var location = WeatherLocation(
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: UUID()
        )
        location.placeName = "東京都新宿区"
        #expect(location.placeName == "東京都新宿区")
    }

    // MARK: - Equatable Tests

    @Test
    func weatherLocation_isEquatable_whenAllPropertiesMatch() {
        let id = UUID()
        let userGroupID = UUID()
        let location1 = WeatherLocation(
            id: id,
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )
        let location2 = WeatherLocation(
            id: id,
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )

        #expect(location1 == location2)
    }

    @Test
    func weatherLocation_isNotEqual_whenIdDiffers() {
        let userGroupID = UUID()
        let location1 = WeatherLocation(
            id: UUID(),
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )
        let location2 = WeatherLocation(
            id: UUID(),
            label: "家",
            latitude: 35.6762,
            longitude: 139.6503,
            placeName: "東京都渋谷区",
            userGroupID: userGroupID
        )

        #expect(location1 != location2)
    }
}
