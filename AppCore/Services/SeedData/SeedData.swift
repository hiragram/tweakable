import Foundation

/// シードデータ（初期レシピ）を提供する
public enum SeedData {
    /// シードデータのカテゴリ名
    static let categoryName = "Eitan"

    /// 現在のロケールに基づいたシードレシピを返す
    static func recipes() -> [Recipe] {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        if languageCode == "ja" {
            return japaneseRecipes
        } else {
            return englishRecipes
        }
    }
}
