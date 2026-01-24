import Foundation

/// Preview用の固定日付を提供する
///
/// スナップショットテストで日付が変わっても同じ結果になるよう、
/// 固定の日付を使用する
public enum PreviewDate {
    /// 固定の基準日（2025年12月8日 月曜日）
    ///
    /// 月曜始まりの週を表示するために月曜日を選択
    /// 12月の日付を使用して、"12/12"のような長い日付でもレイアウトが崩れないことを確認
    public static var today: Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 12
        components.day = 8
        components.hour = 10
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    /// 固定のカレンダー（日本ロケール）
    public static var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ja_JP")
        return calendar
    }

    /// 週の日付配列を生成（today から 7日間）
    public static func weekDates() -> [Date] {
        (0..<7).map { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)!
        }
    }
}
