import Prefire
import SwiftUI
import TipKit

// MARK: - Accessibility Identifiers

enum ShoppingListsAccessibilityID {
    static let emptyView = "shoppingLists_view_empty"
    static let list = "shoppingLists_list"
    static let createButton = "shoppingLists_button_create"
    static func listRow(_ id: UUID) -> String { "shoppingLists_button_list_\(id.uuidString)" }
    static func deleteButton(_ id: UUID) -> String { "shoppingLists_button_delete_\(id.uuidString)" }
}

// MARK: - ShoppingListsView

/// 買い物リスト一覧画面
struct ShoppingListsView: View {
    private let ds = DesignSystem.default

    let shoppingLists: [ShoppingListDTO]
    let isLoading: Bool
    let onListTapped: (ShoppingListDTO) -> Void
    let onDeleteTapped: (UUID) -> Void
    let onCreateTapped: () -> Void

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if shoppingLists.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .background(ds.colors.backgroundPrimary.color)
        .navigationTitle(String(localized: .shoppingListsTitle))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCreateTapped) {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier(ShoppingListsAccessibilityID.createButton)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ProgressView()
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: ds.spacing.lg) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(ds.colors.textTertiary.color)

            Text(.shoppingListsEmptyTitle)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            Text(.shoppingListsEmptyMessage)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)

            TipView(CreateShoppingListTip())
                .padding(.horizontal, ds.spacing.md)

            Button(action: onCreateTapped) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(.shoppingListsCreateButton)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, ds.spacing.xl)
                .padding(.vertical, ds.spacing.md)
                .background(ds.colors.primaryBrand.color)
                .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
            }
            .accessibilityIdentifier(ShoppingListsAccessibilityID.createButton)
        }
        .padding(ds.spacing.xl)
        .accessibilityIdentifier(ShoppingListsAccessibilityID.emptyView)
    }

    // MARK: - List View

    private var listView: some View {
        ScrollView {
            VStack(spacing: ds.spacing.md) {
                ForEach(shoppingLists) { list in
                    listRow(list)
                }
            }
            .padding(.horizontal, ds.spacing.lg)
            .padding(.vertical, ds.spacing.md)
        }
        .accessibilityIdentifier(ShoppingListsAccessibilityID.list)
    }

    private func listRow(_ list: ShoppingListDTO) -> some View {
        Button(action: { onListTapped(list) }) {
            HStack(spacing: ds.spacing.md) {
                // Icon
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundColor(ds.colors.primaryBrand.color)
                    .frame(width: 44, height: 44)
                    .background(ds.colors.primaryBrand.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.sm))

                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(list.name)
                        .font(.headline)
                        .foregroundColor(ds.colors.textPrimary.color)
                        .lineLimit(1)

                    HStack(spacing: ds.spacing.sm) {
                        // Item count
                        Label(
                            String(localized: .shoppingListsItemCount(list.items.count)),
                            systemImage: "checkmark.circle"
                        )
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)

                        // Recipe count
                        Label(
                            String(localized: .shoppingListsRecipeCount(list.recipeIDs.count)),
                            systemImage: "fork.knife"
                        )
                        .font(.caption)
                        .foregroundColor(ds.colors.textTertiary.color)
                    }

                    // Checked progress
                    let checkedCount = list.items.filter { $0.isChecked }.count
                    if !list.items.isEmpty {
                        ProgressView(value: Double(checkedCount), total: Double(list.items.count))
                            .tint(ds.colors.primaryBrand.color)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ds.colors.textTertiary.color)
            }
            .padding(ds.spacing.md)
            .background(ds.colors.backgroundSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(ShoppingListsAccessibilityID.listRow(list.id))
    }
}

// MARK: - Preview

#Preview("ShoppingLists Empty") {
    NavigationStack {
        ShoppingListsView(
            shoppingLists: [],
            isLoading: false,
            onListTapped: { _ in },
            onDeleteTapped: { _ in },
            onCreateTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("ShoppingLists Loading") {
    NavigationStack {
        ShoppingListsView(
            shoppingLists: [],
            isLoading: true,
            onListTapped: { _ in },
            onDeleteTapped: { _ in },
            onCreateTapped: {}
        )
    }
    .prefireEnabled()
}

#Preview("ShoppingLists With Items") {
    NavigationStack {
        ShoppingListsView(
            shoppingLists: [
                ShoppingListDTO(
                    id: UUID(),
                    name: "今週の買い物",
                    createdAt: Date(),
                    updatedAt: Date(),
                    recipeIDs: [UUID(), UUID()],
                    items: [
                        ShoppingListItemDTO(
                            id: UUID(),
                            name: "鶏もも肉",
                            totalAmount: "400g",
                            category: "肉",
                            isChecked: true,
                            breakdowns: []
                        ),
                        ShoppingListItemDTO(
                            id: UUID(),
                            name: "玉ねぎ",
                            totalAmount: "3個",
                            category: "野菜",
                            isChecked: false,
                            breakdowns: []
                        ),
                        ShoppingListItemDTO(
                            id: UUID(),
                            name: "人参",
                            totalAmount: "2本",
                            category: "野菜",
                            isChecked: false,
                            breakdowns: []
                        )
                    ]
                ),
                ShoppingListDTO(
                    id: UUID(),
                    name: "パーティー用",
                    createdAt: Date(),
                    updatedAt: Date(),
                    recipeIDs: [UUID()],
                    items: [
                        ShoppingListItemDTO(
                            id: UUID(),
                            name: "牛肉",
                            totalAmount: "500g",
                            category: "肉",
                            isChecked: false,
                            breakdowns: []
                        )
                    ]
                )
            ],
            isLoading: false,
            onListTapped: { _ in },
            onDeleteTapped: { _ in },
            onCreateTapped: {}
        )
    }
    .prefireEnabled()
}
