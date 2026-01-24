import Foundation

/// 天気予報を取得する地点
public struct WeatherLocation: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var label: String
    public var latitude: Double
    public var longitude: Double
    public var placeName: String
    public let userGroupID: UUID

    public init(
        id: UUID = UUID(),
        label: String,
        latitude: Double,
        longitude: Double,
        placeName: String,
        userGroupID: UUID
    ) {
        self.id = id
        self.label = label
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
        self.userGroupID = userGroupID
    }
}
