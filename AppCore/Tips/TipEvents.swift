//
//  TipEvents.swift
//  AppCore
//

import TipKit

/// TipKitのイベント定義
///
/// 各イベントはTipの表示条件として使用される。
/// 各Tipは対応するイベントのdonation数が0の時に表示される。
/// アクション完了時に `sendDonation()` を呼び出すことで、
/// donation数が1以上になり、そのイベントに紐づくTipが非表示になる。
enum TipEvents {
    // MARK: - Onboarding Events

    /// オンボーディングを完了したイベント
    ///
    /// オンボーディング完了後にTipを表示するための条件として使用。
    /// `AddRecipeButtonTip` はこのイベントが1回以上donateされるまで表示されない。
    static let onboardingCompleted = Tips.Event(id: "onboardingCompleted")

    // MARK: - Recipe Events

    /// レシピを追加したイベント
    static let recipeAdded = Tips.Event(id: "recipeAdded")

    /// レシピを保存したイベント
    static let recipeSaved = Tips.Event(id: "recipeSaved")

    // MARK: - Substitution Events

    /// 食材の置き換えを実行したイベント
    static let ingredientSubstituted = Tips.Event(id: "ingredientSubstituted")

    /// 調理工程の置き換えを実行したイベント
    static let stepSubstituted = Tips.Event(id: "stepSubstituted")

    // MARK: - Shopping List Events

    /// 買い物リストを作成したイベント
    static let shoppingListCreated = Tips.Event(id: "shoppingListCreated")

    /// 買い物リストのアイテムをチェックしたイベント
    static let shoppingListItemChecked = Tips.Event(id: "shoppingListItemChecked")

    // MARK: - Subscription Events

    /// Paywallを表示したイベント
    static let paywallViewed = Tips.Event(id: "paywallViewed")
}
