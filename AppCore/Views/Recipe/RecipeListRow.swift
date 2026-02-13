import Prefire
import SwiftUI

// MARK: - RecipeListRow

/// レシピリストの行UI（検索結果画面・買い物リスト作成画面で共用）
struct RecipeListRow<TrailingAccessory: View>: View {
    private let ds = DesignSystem.default

    let recipe: Recipe
    let matchFields: SearchMatchField?
    let accessibilityID: String
    @ViewBuilder let trailingAccessory: () -> TrailingAccessory
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack(alignment: .top, spacing: ds.spacing.md) {
                RecipeImageView(source: recipe.imageURLs.first)

                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .lineLimit(1)

                    if let description = recipe.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                            .lineLimit(1)
                    }

                    if let matchFields {
                        matchBadgesView(matchFields)
                    }
                }

                Spacer()

                trailingAccessory()
            }
            .padding(.vertical, ds.spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Match Badges

    private func matchBadgesView(_ matchFields: SearchMatchField) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if matchFields.contains(.title) {
                matchIndicator(String(localized: .searchResultsMatchTitle))
            }
            if matchFields.contains(.description) {
                matchIndicator(String(localized: .searchResultsMatchDescription))
            }
            if matchFields.contains(.ingredients) {
                matchIndicator(String(localized: .searchResultsMatchIngredients))
            }
            if matchFields.contains(.steps) {
                matchIndicator(String(localized: .searchResultsMatchSteps))
            }
        }
    }

    private func matchIndicator(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(ds.colors.textTertiary.color)
    }
}

// MARK: - Preview

#Preview("RecipeListRow With MatchFields") {
    VStack(spacing: 0) {
        RecipeListRow(
            recipe: SearchResultsPreviewData.recipe1,
            matchFields: [.title, .ingredients],
            accessibilityID: "preview_row_1",
            trailingAccessory: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignSystem.default.colors.textTertiary.color)
            },
            onTapped: {}
        )
        .padding(.horizontal, DesignSystem.default.spacing.md)

        Divider()
            .padding(.leading, 60 + DesignSystem.default.spacing.md * 2)

        RecipeListRow(
            recipe: SearchResultsPreviewData.recipe2,
            matchFields: [.title, .description, .ingredients, .steps],
            accessibilityID: "preview_row_2",
            trailingAccessory: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignSystem.default.colors.textTertiary.color)
            },
            onTapped: {}
        )
        .padding(.horizontal, DesignSystem.default.spacing.md)
    }
    .prefireEnabled()
}

#Preview("RecipeListRow Without MatchFields") {
    VStack(spacing: 0) {
        RecipeListRow(
            recipe: SearchResultsPreviewData.recipe1,
            matchFields: nil,
            accessibilityID: "preview_row_no_match_1",
            trailingAccessory: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignSystem.default.colors.primaryBrand.color)
            },
            onTapped: {}
        )
        .padding(.horizontal, DesignSystem.default.spacing.md)

        Divider()
            .padding(.leading, 60 + DesignSystem.default.spacing.md * 2)

        RecipeListRow(
            recipe: SearchResultsPreviewData.recipe2,
            matchFields: nil,
            accessibilityID: "preview_row_no_match_2",
            trailingAccessory: {
                Image(systemName: "circle")
                    .foregroundColor(DesignSystem.default.colors.textTertiary.color)
            },
            onTapped: {}
        )
        .padding(.horizontal, DesignSystem.default.spacing.md)
    }
    .prefireEnabled()
}
