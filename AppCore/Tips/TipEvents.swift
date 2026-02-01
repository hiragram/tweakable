//
//  TipEvents.swift
//  AppCore
//

import TipKit

/// TipKitのイベント定義
///
/// 各イベントはTipの無効化条件として使用される。
/// アクション完了時に `sendDonation()` を呼び出すことで、
/// そのイベントに紐づくTipが非表示になる。
enum TipEvents {
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
