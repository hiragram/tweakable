//
//  AppTips.swift
//  AppCore
//

import SwiftUI
import TipKit

// MARK: - Recipe Home Tips

/// レシピ追加ボタンのTip（空の状態で表示）
struct AddRecipeButtonTip: Tip {
    var title: Text {
        Text(.tipAddRecipeTitle)
    }

    var message: Text? {
        Text(.tipAddRecipeMessage)
    }

    var image: Image? {
        Image(systemName: "plus.circle")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.recipeAdded) {
                $0.donations.count == 0
            }
        ]
    }
}

// MARK: - Recipe View Tips

/// 食材置き換えTip
struct IngredientSubstitutionTip: Tip {
    var title: Text {
        Text(.tipIngredientSubstitutionTitle)
    }

    var message: Text? {
        Text(.tipIngredientSubstitutionMessage)
    }

    var image: Image? {
        Image(systemName: "arrow.triangle.2.circlepath")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.ingredientSubstituted) {
                $0.donations.count == 0
            }
        ]
    }
}

/// 調理工程置き換えTip
struct StepSubstitutionTip: Tip {
    var title: Text {
        Text(.tipStepSubstitutionTitle)
    }

    var message: Text? {
        Text(.tipStepSubstitutionMessage)
    }

    var image: Image? {
        Image(systemName: "arrow.triangle.2.circlepath")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.stepSubstituted) {
                $0.donations.count == 0
            }
        ]
    }
}

/// レシピ保存Tip
struct SaveRecipeTip: Tip {
    var title: Text {
        Text(.tipSaveRecipeTitle)
    }

    var message: Text? {
        Text(.tipSaveRecipeMessage)
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.down")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.recipeSaved) {
                $0.donations.count == 0
            }
        ]
    }
}

// MARK: - Shopping List Tips

/// 買い物リスト作成Tip（空の状態で表示）
struct CreateShoppingListTip: Tip {
    var title: Text {
        Text(.tipCreateShoppingListTitle)
    }

    var message: Text? {
        Text(.tipCreateShoppingListMessage)
    }

    var image: Image? {
        Image(systemName: "cart.badge.plus")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.shoppingListCreated) {
                $0.donations.count == 0
            }
        ]
    }
}

/// 買い物リストチェックオフTip
struct ShoppingListCheckoffTip: Tip {
    var title: Text {
        Text(.tipShoppingListCheckoffTitle)
    }

    var message: Text? {
        Text(.tipShoppingListCheckoffMessage)
    }

    var image: Image? {
        Image(systemName: "checkmark.circle")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.shoppingListItemChecked) {
                $0.donations.count == 0
            }
        ]
    }
}

// MARK: - Premium Tips

/// プレミアム機能訴求Tip（非プレミアムユーザー向け）
struct PremiumSubstitutionTip: Tip {
    var title: Text {
        Text(.tipPremiumSubstitutionTitle)
    }

    var message: Text? {
        Text(.tipPremiumSubstitutionMessage)
    }

    var image: Image? {
        Image(systemName: "star.fill")
    }

    var rules: [Rule] {
        [
            #Rule(TipEvents.paywallViewed) {
                $0.donations.count == 0
            }
        ]
    }
}
