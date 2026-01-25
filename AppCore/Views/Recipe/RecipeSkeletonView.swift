import SwiftUI

// MARK: - RecipeSkeletonView

struct RecipeSkeletonView: View {
    private let ds = DesignSystem.default

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ds.spacing.lg) {
                // Title skeleton
                SkeletonBlock(width: 200, height: 28)

                // Image skeleton
                SkeletonBlock(width: .infinity, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))

                // Ingredients section skeleton
                VStack(alignment: .leading, spacing: ds.spacing.sm) {
                    SkeletonBlock(width: 60, height: 20)

                    VStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { _ in
                            ingredientRowSkeleton
                            Divider()
                                .background(ds.colors.separator.color)
                        }
                    }
                    .background(ds.colors.backgroundSecondary.color)
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
                }

                // Steps section skeleton
                VStack(alignment: .leading, spacing: ds.spacing.sm) {
                    SkeletonBlock(width: 60, height: 20)

                    VStack(spacing: ds.spacing.sm) {
                        ForEach(0..<4, id: \.self) { _ in
                            stepRowSkeleton
                        }
                    }
                }
            }
            .padding(ds.spacing.md)
        }
    }

    private var ingredientRowSkeleton: some View {
        HStack {
            VStack(alignment: .leading, spacing: ds.spacing.xxs) {
                SkeletonBlock(width: 100, height: 16)
                SkeletonBlock(width: 60, height: 14)
            }
            Spacer()
        }
        .padding(ds.spacing.md)
    }

    private var stepRowSkeleton: some View {
        HStack(alignment: .top, spacing: ds.spacing.md) {
            SkeletonBlock(width: 32, height: 32)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: ds.spacing.xs) {
                SkeletonBlock(width: .infinity, height: 16)
                SkeletonBlock(width: 180, height: 16)
            }

            Spacer()
        }
        .padding(ds.spacing.md)
        .background(ds.colors.backgroundSecondary.color)
        .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))
    }
}

// MARK: - SkeletonBlock

struct SkeletonBlock: View {
    let width: CGFloat?
    let height: CGFloat
    private let ds = DesignSystem.default

    @State private var isAnimating = false

    init(width: CGFloat, height: CGFloat) {
        self.width = width == .infinity ? nil : width
        self.height = height
    }

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ds.colors.backgroundTertiary.color,
                        ds.colors.backgroundSecondary.color,
                        ds.colors.backgroundTertiary.color
                    ]),
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.xs))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Preview

#Preview("Skeleton") {
    NavigationStack {
        RecipeSkeletonView()
            .navigationTitle("レシピ")
    }
    .prefireEnabled()
}
