import Foundation

/// ユーザーグループ（家族など）
public struct UserGroup: Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public let createdAt: Date
    /// 有効な曜日の設定（曜日番号 → 有効/無効）
    /// キー: Foundation.Calendarの曜日番号（1=日曜, 2=月曜, ..., 7=土曜）
    /// デフォルト: 月〜金のみON
    public var enabledWeekdays: [Int: Bool]

    /// 月〜金のみONのデフォルト設定
    public static let defaultEnabledWeekdays: [Int: Bool] = [
        1: false, // 日曜
        2: true,  // 月曜
        3: true,  // 火曜
        4: true,  // 水曜
        5: true,  // 木曜
        6: true,  // 金曜
        7: false  // 土曜
    ]

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        enabledWeekdays: [Int: Bool] = UserGroup.defaultEnabledWeekdays
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.enabledWeekdays = enabledWeekdays
    }
}
