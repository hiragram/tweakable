import Foundation

/// シードデータ（初期レシピ）を提供する
public enum SeedData {
    /// シードデータのカテゴリ名
    static let categoryName = "Eitan"

    /// 指定された言語コードに基づいたシードレシピを返す
    static func recipes(for languageCode: String) -> [Recipe] {
        if languageCode == "ja" {
            return japaneseRecipes
        } else {
            return englishRecipes
        }
    }

    /// 現在のロケールに基づいたシードレシピを返す
    static func recipes() -> [Recipe] {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return recipes(for: languageCode)
    }
}
