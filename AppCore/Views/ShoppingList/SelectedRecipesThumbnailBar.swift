import NukeUI
import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum SelectedRecipesThumbnailBarAccessibilityID {
    static let bar = "selectedRecipesThumbnailBar"
    static func recipe(_ id: UUID) -> String { "selectedRecipesThumbnailBar_recipe_\(id.uuidString)" }
    static func remove(_ id: UUID) -> String { "selectedRecipesThumbnailBar_remove_\(id.uuidString)" }
}

// MARK: - SelectedRecipesThumbnailBar

struct SelectedRecipesThumbnailBar: View {
    private let ds = DesignSystem.default

    let selectedRecipes: [Recipe]
    let onRemoveTapped: (UUID) -> Void

    var body: some View {
        if !selectedRecipes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ds.spacing.sm) {
                    ForEach(selectedRecipes) { recipe in
                        recipeThumbnail(recipe)
                    }
                }
                .padding(.horizontal, ds.spacing.md)
                .padding(.vertical, ds.spacing.xs)
            }
            .accessibilityIdentifier(SelectedRecipesThumbnailBarAccessibilityID.bar)
        }
    }

    // MARK: - Recipe Thumbnail

    private func recipeThumbnail(_ recipe: Recipe) -> some View {
        VStack(spacing: ds.spacing.xxs) {
            thumbnailImage(recipe.imageURLs.first)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.xs))
                .overlay(alignment: .topTrailing) {
                    removeButton(recipe.id)
                }
                .accessibilityIdentifier(SelectedRecipesThumbnailBarAccessibilityID.recipe(recipe.id))

            Text(recipe.title)
                .font(.caption2)
                .foregroundColor(ds.colors.textSecondary.color)
                .lineLimit(1)
                .frame(width: 50)
        }
    }

    // MARK: - Remove Button

    private func removeButton(_ recipeID: UUID) -> some View {
        Button {
            onRemoveTapped(recipeID)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    ds.colors.textTertiary.color,
                    ds.colors.backgroundPrimary.color
                )
        }
        .offset(x: 4, y: -4)
        .accessibilityIdentifier(SelectedRecipesThumbnailBarAccessibilityID.remove(recipeID))
    }

    // MARK: - Thumbnail Image

    private func thumbnailImage(_ source: ImageSource?) -> some View {
        Group {
            if let source = source {
                switch source {
                case .remote(let url):
                    LazyImage(url: url) { state in
                        if state.isLoading {
                            placeholderImage
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(0.5)
                                }
                        } else if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            placeholderImage
                        }
                    }
                case .local(let fileURL):
                    if let data = try? Data(contentsOf: fileURL),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderImage
                    }
                case .uiImage(let uiImage):
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .bundled(let name):
                    if let uiImage = UIImage(named: name, in: .app, with: nil) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(ds.colors.backgroundSecondary.color)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.system(size: 16))
                    .foregroundColor(ds.colors.textTertiary.color)
            }
    }
}

// MARK: - Preview

#Preview("ThumbnailBar Empty") {
    SelectedRecipesThumbnailBar(
        selectedRecipes: [],
        onRemoveTapped: { _ in }
    )
    .prefireEnabled()
}

#Preview("ThumbnailBar Single") {
    SelectedRecipesThumbnailBar(
        selectedRecipes: [
            Recipe(
                title: "鶏の照り焼き",
                imageURLs: [.previewPlaceholder()],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
        ],
        onRemoveTapped: { _ in }
    )
    .prefireEnabled()
}

#Preview("ThumbnailBar Multiple") {
    SelectedRecipesThumbnailBar(
        selectedRecipes: [
            Recipe(
                title: "鶏の照り焼き",
                imageURLs: [.previewPlaceholder()],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
            Recipe(
                title: "カレーライス",
                imageURLs: [.previewPlaceholder(color: .systemBrown)],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
            Recipe(
                title: "ミネストローネスープ",
                imageURLs: [.previewPlaceholder(color: .systemRed)],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
            Recipe(
                title: "サラダ",
                imageURLs: [],
                ingredientsInfo: Ingredients(sections: []),
                stepSections: []
            ),
        ],
        onRemoveTapped: { _ in }
    )
    .prefireEnabled()
}
