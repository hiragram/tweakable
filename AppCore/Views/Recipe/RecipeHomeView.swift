import NukeUI
import Prefire
import SwiftUI
import TipKit

// MARK: - Accessibility Identifiers

enum RecipeHomeAccessibilityID {
    static let emptyView = "recipeHome_view_empty"
    static let emptyAddButton = "recipeHome_button_emptyAdd"
    static let grid = "recipeHome_grid"
    static func recipeCard(_ id: UUID) -> String { "recipeHome_button_recipe_\(id.uuidString)" }
    static func deleteButton(_ id: UUID) -> String { "recipeHome_button_delete_\(id.uuidString)" }
}

// MARK: - RecipeHomeView

/// マイレシピ一覧画面（2列グリッド表示）
struct RecipeHomeView: View {
    private let ds = DesignSystem.default

    let recipes: [Recipe]
    let categories: [RecipeCategory]
    let selectedCategoryID: UUID?
    let isLoading: Bool
    let onRecipeTapped: (Recipe) -> Void
    let onAddTapped: () -> Void
    let onDeleteConfirmed: (UUID) -> Void
    let onCategoryTapped: (UUID?) -> Void
    let onAddCategoryTapped: () -> Void
    let onCategoryLongPressed: (RecipeCategory) -> Void

    @State private var showDeleteConfirmation: Bool = false
    @State private var recipeToDelete: UUID?

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        // カテゴリチップはコンテンツ切り替え(empty/grid)の外に配置し、
        // 空カテゴリ選択時でも常にフィルタ操作できるようにする
        VStack(spacing: 0) {
            if !isLoading && !categories.isEmpty {
                categoryChipsView
                    .padding(.vertical, ds.spacing.sm)
            }

            Group {
                if isLoading {
                    loadingView
                } else if recipes.isEmpty {
                    emptyView
                } else {
                    recipeGridView
                }
            }
        }
        .background(ds.colors.backgroundPrimary.color)
        .confirmationDialog(
            String(localized: .recipeDeleteConfirmationTitle),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: .commonDelete), role: .destructive) {
                if let id = recipeToDelete {
                    onDeleteConfirmed(id)
                }
                recipeToDelete = nil
            }
            Button(String(localized: .commonCancel), role: .cancel) {
                recipeToDelete = nil
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: ds.spacing.lg) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(ds.colors.textTertiary.color)

            Text(.myRecipesEmptyTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(ds.colors.textPrimary.color)

            Text(.myRecipesEmptyMessage)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ds.spacing.xl)

            Button(action: onAddTapped) {
                HStack {
                    Image(systemName: "plus")
                    Text(.myRecipesEmptyButton)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, ds.spacing.xl)
                .padding(.vertical, ds.spacing.md)
                .background(ds.colors.primaryBrand.color)
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            }
            .popoverTip(AddRecipeButtonTip())
            .accessibilityIdentifier(RecipeHomeAccessibilityID.emptyAddButton)
            .padding(.top, ds.spacing.md)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier(RecipeHomeAccessibilityID.emptyView)
    }

    // MARK: - Category Filter Chips

    private var categoryChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ds.spacing.xs) {
                // 「すべて」チップ
                categoryChip(
                    label: String(localized: .categoryAll),
                    isSelected: selectedCategoryID == nil,
                    accessibilityID: "recipeHome_button_categoryAll"
                ) {
                    onCategoryTapped(nil)
                }

                // カテゴリチップ
                ForEach(categories) { category in
                    categoryChip(
                        label: category.name,
                        isSelected: selectedCategoryID == category.id,
                        accessibilityID: "recipeHome_button_category_\(category.id.uuidString)"
                    ) {
                        onCategoryTapped(category.id)
                    }
                    .onLongPressGesture {
                        onCategoryLongPressed(category)
                    }
                }

                // 「+」追加ボタン
                Button(action: onAddCategoryTapped) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(ds.colors.textSecondary.color)
                        .padding(.horizontal, ds.spacing.sm)
                        .padding(.vertical, ds.spacing.xs)
                        .background(ds.colors.backgroundSecondary.color)
                        .clipShape(Capsule())
                }
                .frame(minHeight: 44)
                .contentShape(Capsule())
                .accessibilityIdentifier("recipeHome_button_addCategory")
            }
            .padding(.horizontal, ds.spacing.md)
        }
    }

    private func categoryChip(
        label: String,
        isSelected: Bool,
        accessibilityID: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : ds.colors.textPrimary.color)
                .padding(.horizontal, ds.spacing.sm)
                .padding(.vertical, ds.spacing.xs)
                .background(isSelected ? ds.colors.primaryBrand.color : ds.colors.backgroundSecondary.color)
                .clipShape(Capsule())
        }
        .frame(minHeight: 44)
        .contentShape(Capsule())
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Recipe Grid View

    private var recipeGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(recipes) { recipe in
                    recipeCard(recipe)
                }
            }
            .padding(.horizontal, ds.spacing.md)
            .padding(.vertical, ds.spacing.sm)
        }
        .accessibilityIdentifier(RecipeHomeAccessibilityID.grid)
    }

    private func recipeCard(_ recipe: Recipe) -> some View {
        Button(action: { onRecipeTapped(recipe) }) {
            recipeImage(recipe.imageURLs.first)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    // Gradient overlay + Title & meta info
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        VStack(alignment: .leading, spacing: ds.spacing.xxs) {
                            Text(recipe.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)

                            HStack(spacing: ds.spacing.xs) {
                                Label(
                                    "\(recipe.ingredientsInfo.allItems.count)",
                                    systemImage: "carrot.fill"
                                )
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))

                                Label(
                                    "\(recipe.allSteps.count)",
                                    systemImage: "list.number"
                                )
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(ds.spacing.sm)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.lg))
                .shadow(
                    color: ds.shadow.sm.color,
                    radius: ds.shadow.sm.radius,
                    x: ds.shadow.sm.x,
                    y: ds.shadow.sm.y
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(RecipeHomeAccessibilityID.recipeCard(recipe.id))
        .contextMenu {
            Button(role: .destructive) {
                recipeToDelete = recipe.id
                showDeleteConfirmation = true
            } label: {
                Label(String(localized: .commonDelete), systemImage: "trash")
            }
            .accessibilityIdentifier(RecipeHomeAccessibilityID.deleteButton(recipe.id))
        }
    }

    private func recipeImage(_ source: ImageSource?) -> some View {
        Color.clear.overlay {
            Group {
                if let source = source {
                    switch source {
                    case .remote(let url):
                        LazyImage(url: url) { state in
                            if state.isLoading {
                                placeholderImage
                                    .overlay {
                                        ProgressView()
                                            .scaleEffect(0.8)
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
        .clipped()
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        ds.colors.backgroundTertiary.color,
                        ds.colors.backgroundSecondary.color
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.largeTitle)
                    .foregroundColor(ds.colors.textTertiary.color)
            }
    }
}

// MARK: - Preview

#Preview("RecipeHome Empty") {
    NavigationStack {
        RecipeHomeView(
            recipes: [],
            categories: [],
            selectedCategoryID: nil,
            isLoading: false,
            onRecipeTapped: { _ in },
            onAddTapped: {},
            onDeleteConfirmed: { _ in },
            onCategoryTapped: { _ in },
            onAddCategoryTapped: {},
            onCategoryLongPressed: { _ in }
        )
        .navigationTitle(String(localized: .myRecipesTitle))
    }
    .prefireEnabled()
}

#Preview("RecipeHome Loading") {
    NavigationStack {
        RecipeHomeView(
            recipes: [],
            categories: [],
            selectedCategoryID: nil,
            isLoading: true,
            onRecipeTapped: { _ in },
            onAddTapped: {},
            onDeleteConfirmed: { _ in },
            onCategoryTapped: { _ in },
            onAddCategoryTapped: {},
            onCategoryLongPressed: { _ in }
        )
        .navigationTitle(String(localized: .myRecipesTitle))
    }
    .prefireEnabled()
}

#Preview("RecipeHome With Recipes") {
    NavigationStack {
        RecipeHomeView(
            recipes: [
                Recipe(
                    title: "鶏の照り焼き",
                    description: "甘辛いタレが食欲をそそる定番の照り焼きチキン。",
                    imageURLs: [.previewPlaceholder()],
                    ingredientsInfo: Ingredients(
                        servings: "2人分",
                        sections: [
                            IngredientSection(items: [
                                Ingredient(name: "鶏もも肉", amount: "2枚"),
                                Ingredient(name: "醤油", amount: "大さじ3"),
                                Ingredient(name: "みりん", amount: "大さじ2")
                            ])
                        ]
                    ),
                    stepSections: [
                        CookingStepSection(items: [
                            CookingStep(stepNumber: 1, instruction: "鶏もも肉を切る"),
                            CookingStep(stepNumber: 2, instruction: "焼く")
                        ])
                    ]
                ),
                Recipe(
                    title: "カレーライス",
                    description: "家庭の定番カレー",
                    imageURLs: [.previewPlaceholder(color: .systemBrown)],
                    ingredientsInfo: Ingredients(
                        servings: "4人分",
                        sections: [
                            IngredientSection(items: [
                                Ingredient(name: "豚肉", amount: "300g"),
                                Ingredient(name: "玉ねぎ", amount: "2個"),
                                Ingredient(name: "人参", amount: "1本"),
                                Ingredient(name: "じゃがいも", amount: "2個"),
                                Ingredient(name: "カレールー", amount: "1箱")
                            ])
                        ]
                    ),
                    stepSections: [
                        CookingStepSection(items: [
                            CookingStep(stepNumber: 1, instruction: "野菜を切る"),
                            CookingStep(stepNumber: 2, instruction: "肉を炒める"),
                            CookingStep(stepNumber: 3, instruction: "野菜を加えて煮込む"),
                            CookingStep(stepNumber: 4, instruction: "ルーを溶かす")
                        ])
                    ]
                ),
                Recipe(
                    title: "肉じゃが",
                    description: nil,
                    imageURLs: [],
                    ingredientsInfo: Ingredients(
                        servings: "3人分",
                        sections: [
                            IngredientSection(items: [
                                Ingredient(name: "牛肉", amount: "200g"),
                                Ingredient(name: "じゃがいも", amount: "3個")
                            ])
                        ]
                    ),
                    stepSections: [
                        CookingStepSection(items: [
                            CookingStep(stepNumber: 1, instruction: "材料を切る"),
                            CookingStep(stepNumber: 2, instruction: "煮込む")
                        ])
                    ]
                ),
                Recipe(
                    title: "味噌汁",
                    description: nil,
                    imageURLs: [.previewPlaceholder(color: .systemOrange)],
                    ingredientsInfo: Ingredients(
                        servings: "2人分",
                        sections: [
                            IngredientSection(items: [
                                Ingredient(name: "味噌", amount: "大さじ2"),
                                Ingredient(name: "豆腐", amount: "1/2丁")
                            ])
                        ]
                    ),
                    stepSections: [
                        CookingStepSection(items: [
                            CookingStep(stepNumber: 1, instruction: "だしを取る"),
                            CookingStep(stepNumber: 2, instruction: "味噌を溶く")
                        ])
                    ]
                )
            ],
            categories: [
                RecipeCategory(name: "和食"),
                RecipeCategory(name: "中華"),
                RecipeCategory(name: "メイン"),
                RecipeCategory(name: "スープ")
            ],
            selectedCategoryID: nil,
            isLoading: false,
            onRecipeTapped: { _ in },
            onAddTapped: {},
            onDeleteConfirmed: { _ in },
            onCategoryTapped: { _ in },
            onAddCategoryTapped: {},
            onCategoryLongPressed: { _ in }
        )
        .navigationTitle(String(localized: .myRecipesTitle))
    }
    .prefireEnabled()
}
