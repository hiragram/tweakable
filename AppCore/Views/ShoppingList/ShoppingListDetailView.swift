import Prefire
import SwiftUI

// MARK: - Accessibility Identifiers

enum ShoppingListDetailAccessibilityID {
    static let list = "shoppingListDetail_list"
    static let emptyView = "shoppingListDetail_view_empty"
    static func itemRow(_ id: UUID) -> String { "shoppingListDetail_button_item_\(id.uuidString)" }
    static func itemCheckbox(_ id: UUID) -> String { "shoppingListDetail_button_checkbox_\(id.uuidString)" }
    static func breakdownSection(_ id: UUID) -> String { "shoppingListDetail_section_breakdown_\(id.uuidString)" }
}

// MARK: - ShoppingListDetailView

/// 買い物リスト詳細画面
struct ShoppingListDetailView: View {
    private let ds = DesignSystem.default

    let shoppingList: ShoppingListDTO
    let isUpdatingItem: Bool
    let onItemCheckedChanged: (UUID, Bool) -> Void

    @State private var expandedItemIDs: Set<UUID> = []

    /// カテゴリでグループ化したアイテム（パフォーマンス最適化）
    private var groupedItemsByCategory: (groups: [String: [ShoppingListItemDTO]], sortedKeys: [String]) {
        let grouped = Dictionary(grouping: shoppingList.items) { $0.category ?? "" }
        let sortedKeys = grouped.keys.sorted { lhs, rhs in
            // Empty category goes last
            if lhs.isEmpty { return false }
            if rhs.isEmpty { return true }
            return lhs < rhs
        }
        return (grouped, sortedKeys)
    }

    var body: some View {
        Group {
            if shoppingList.items.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .navigationTitle(shoppingList.name)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: ds.spacing.lg) {
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundColor(ds.colors.textTertiary.color)

            Text(.shoppingListDetailEmptyTitle)
                .font(.headline)
                .foregroundColor(ds.colors.textPrimary.color)

            Text(.shoppingListDetailEmptyMessage)
                .font(.body)
                .foregroundColor(ds.colors.textSecondary.color)
                .multilineTextAlignment(.center)
        }
        .padding(ds.spacing.xl)
        .accessibilityIdentifier(ShoppingListDetailAccessibilityID.emptyView)
    }

    // MARK: - List View

    private var listView: some View {
        ScrollView {
            VStack(spacing: ds.spacing.lg) {
                let (groupedItems, sortedCategories) = groupedItemsByCategory

                ForEach(sortedCategories, id: \.self) { category in
                    VStack(alignment: .leading, spacing: ds.spacing.sm) {
                        // Category header
                        if !category.isEmpty {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(ds.colors.textSecondary.color)
                        }

                        // Items in this category
                        VStack(spacing: 0) {
                            let items = groupedItems[category] ?? []
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                itemRow(item)

                                // Divider between items (not after last)
                                if index < items.count - 1 {
                                    Divider()
                                        .padding(.leading, 52) // Align with text after checkbox
                                }
                            }
                        }
                        .background(ds.colors.backgroundSecondary.color)
                        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
                    }
                }
            }
            .padding(.horizontal, ds.spacing.lg)
            .padding(.vertical, ds.spacing.md)
        }
        .accessibilityIdentifier(ShoppingListDetailAccessibilityID.list)
    }

    private func itemRow(_ item: ShoppingListItemDTO) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(spacing: ds.spacing.md) {
                // Checkbox
                Button(action: {
                    onItemCheckedChanged(item.id, !item.isChecked)
                }) {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(item.isChecked ? ds.colors.primaryBrand.color : ds.colors.textTertiary.color)
                }
                .buttonStyle(.plain)
                .disabled(isUpdatingItem)
                .accessibilityIdentifier(ShoppingListDetailAccessibilityID.itemCheckbox(item.id))

                // Item name and amount
                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(item.name)
                        .font(.body)
                        .foregroundColor(item.isChecked ? ds.colors.textTertiary.color : ds.colors.textPrimary.color)
                        .strikethrough(item.isChecked)

                    if let amount = item.totalAmount {
                        Text(amount)
                            .font(.subheadline)
                            .foregroundColor(ds.colors.textSecondary.color)
                    }
                }

                Spacer()

                // Breakdown toggle (if has breakdowns)
                if !item.breakdowns.isEmpty {
                    Button(action: {
                        withAnimation {
                            if expandedItemIDs.contains(item.id) {
                                expandedItemIDs.remove(item.id)
                            } else {
                                expandedItemIDs.insert(item.id)
                            }
                        }
                    }) {
                        HStack(spacing: ds.spacing.xs) {
                            Text(String(localized: .shoppingListDetailSources(item.breakdowns.count)))
                                .font(.caption)
                                .foregroundColor(ds.colors.textSecondary.color)

                            Image(systemName: expandedItemIDs.contains(item.id) ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(ds.colors.textTertiary.color)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(ds.spacing.md)
            .contentShape(Rectangle())
            .accessibilityIdentifier(ShoppingListDetailAccessibilityID.itemRow(item.id))

            // Breakdown section (expandable)
            if expandedItemIDs.contains(item.id) && !item.breakdowns.isEmpty {
                VStack(alignment: .leading, spacing: ds.spacing.sm) {
                    ForEach(item.breakdowns) { breakdown in
                        HStack(spacing: ds.spacing.sm) {
                            Image(systemName: "fork.knife")
                                .font(.caption)
                                .foregroundColor(ds.colors.textTertiary.color)

                            Text(breakdown.sourceRecipeTitle)
                                .font(.caption)
                                .foregroundColor(ds.colors.textSecondary.color)

                            Spacer()

                            if let amount = breakdown.amount {
                                Text(amount)
                                    .font(.caption)
                                    .foregroundColor(ds.colors.textTertiary.color)
                            }
                        }
                    }
                }
                .padding(.leading, 52) // Align with item name (checkbox width + spacing)
                .padding(.trailing, ds.spacing.md)
                .padding(.bottom, ds.spacing.md)
                .accessibilityIdentifier(ShoppingListDetailAccessibilityID.breakdownSection(item.id))
            }
        }
    }
}

// MARK: - Preview

#Preview("ShoppingListDetail Empty") {
    NavigationStack {
        ShoppingListDetailView(
            shoppingList: ShoppingListDTO(
                id: UUID(),
                name: "空の買い物リスト",
                createdAt: Date(),
                updatedAt: Date(),
                recipeIDs: [],
                items: []
            ),
            isUpdatingItem: false,
            onItemCheckedChanged: { _, _ in }
        )
    }
    .prefireEnabled()
}

#Preview("ShoppingListDetail With Items") {
    NavigationStack {
        ShoppingListDetailView(
            shoppingList: ShoppingListDTO(
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
                        breakdowns: [
                            ShoppingListItemBreakdownDTO(
                                id: UUID(),
                                amount: "200g",
                                sourceRecipeID: UUID(),
                                sourceRecipeTitle: "鶏の照り焼き"
                            ),
                            ShoppingListItemBreakdownDTO(
                                id: UUID(),
                                amount: "200g",
                                sourceRecipeID: UUID(),
                                sourceRecipeTitle: "チキンカレー"
                            )
                        ]
                    ),
                    ShoppingListItemDTO(
                        id: UUID(),
                        name: "豚バラ肉",
                        totalAmount: "300g",
                        category: "肉",
                        isChecked: false,
                        breakdowns: []
                    ),
                    ShoppingListItemDTO(
                        id: UUID(),
                        name: "玉ねぎ",
                        totalAmount: "3個",
                        category: "野菜",
                        isChecked: false,
                        breakdowns: [
                            ShoppingListItemBreakdownDTO(
                                id: UUID(),
                                amount: "1個",
                                sourceRecipeID: UUID(),
                                sourceRecipeTitle: "鶏の照り焼き"
                            ),
                            ShoppingListItemBreakdownDTO(
                                id: UUID(),
                                amount: "2個",
                                sourceRecipeID: UUID(),
                                sourceRecipeTitle: "カレーライス"
                            )
                        ]
                    ),
                    ShoppingListItemDTO(
                        id: UUID(),
                        name: "人参",
                        totalAmount: "2本",
                        category: "野菜",
                        isChecked: false,
                        breakdowns: []
                    ),
                    ShoppingListItemDTO(
                        id: UUID(),
                        name: "醤油",
                        totalAmount: "大さじ5",
                        category: "調味料",
                        isChecked: true,
                        breakdowns: []
                    ),
                    ShoppingListItemDTO(
                        id: UUID(),
                        name: "その他",
                        totalAmount: nil,
                        category: nil,
                        isChecked: false,
                        breakdowns: []
                    )
                ]
            ),
            isUpdatingItem: false,
            onItemCheckedChanged: { _, _ in }
        )
    }
    .prefireEnabled()
}
