import Prefire
import SwiftUI

// MARK: - RecipeSkeletonView

struct RecipeSkeletonView: View {
    private let ds = DesignSystem.default
    @State private var isAnimating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ds.spacing.lg) {
                // Title skeleton
                SkeletonBlock(width: 200, height: 28, isAnimating: isAnimating)

                // Image skeleton
                SkeletonBlock(width: .infinity, height: 150, isAnimating: isAnimating)
                    .clipShape(RoundedRectangle(cornerRadius: ds.cornerRadius.md))

                // Ingredients section skeleton
                VStack(alignment: .leading, spacing: ds.spacing.sm) {
                    SkeletonBlock(width: 60, height: 20, isAnimating: isAnimating)

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
                    SkeletonBlock(width: 60, height: 20, isAnimating: isAnimating)

                    VStack(spacing: ds.spacing.sm) {
                        ForEach(0..<4, id: \.self) { _ in
                            stepRowSkeleton
                        }
                    }
                }
            }
            .padding(ds.spacing.md)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    private var ingredientRowSkeleton: some View {
        HStack {
            VStack(alignment: .leading, spacing: ds.spacing.xxs) {
                SkeletonBlock(width: 100, height: 16, isAnimating: isAnimating)
                SkeletonBlock(width: 60, height: 14, isAnimating: isAnimating)
            }
            Spacer()
        }
        .padding(ds.spacing.md)
    }

    private var stepRowSkeleton: some View {
        HStack(alignment: .top, spacing: ds.spacing.md) {
            SkeletonBlock(width: 32, height: 32, isAnimating: isAnimating)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: ds.spacing.xs) {
                SkeletonBlock(width: .infinity, height: 16, isAnimating: isAnimating)
                SkeletonBlock(width: 180, height: 16, isAnimating: isAnimating)
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
    let isAnimating: Bool
    private let ds = DesignSystem.default

    init(width: CGFloat, height: CGFloat, isAnimating: Bool) {
        self.width = width == .infinity ? nil : width
        self.height = height
        self.isAnimating = isAnimating
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
