import SwiftUI

// MARK: - Accessibility Identifiers

enum CategoryAssignmentAccessibilityID {
    static let list = "categoryAssignment_list"
    static func categoryToggle(_ id: UUID) -> String { "categoryAssignment_toggle_\(id.uuidString)" }
    static let addButton = "categoryAssignment_button_add"
}

// MARK: - CategoryAssignmentView

/// レシピのカテゴリ割り当てシート（チェックリスト形式）
struct CategoryAssignmentView: View {
    private let ds = DesignSystem.default

    let categories: [RecipeCategory]
    let assignedCategoryIDs: Set<UUID>
    let onToggleCategory: (UUID, Bool) -> Void
    let onAddCategoryTapped: () -> Void

    var body: some View {
        List {
            ForEach(categories) { category in
                let isAssigned = assignedCategoryIDs.contains(category.id)
                Button {
                    onToggleCategory(category.id, !isAssigned)
                } label: {
                    HStack {
                        Text(category.name)
                            .foregroundColor(ds.colors.textPrimary.color)
                        Spacer()
                        if isAssigned {
                            Image(systemName: "checkmark")
                                .foregroundColor(ds.colors.primaryBrand.color)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .accessibilityIdentifier(CategoryAssignmentAccessibilityID.categoryToggle(category.id))
            }

            Button(action: onAddCategoryTapped) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text(.categoryAddTitle)
                }
                .foregroundColor(ds.colors.primaryBrand.color)
            }
            .accessibilityIdentifier(CategoryAssignmentAccessibilityID.addButton)
        }
        .accessibilityIdentifier(CategoryAssignmentAccessibilityID.list)
        .navigationTitle(String(localized: .categoryAssignTitle))
        .navigationBarTitleDisplayMode(.inline)
    }
}
