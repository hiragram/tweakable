import SwiftUI

// MARK: - Design System

struct DesignSystem {
    let name: String
    let colors: ColorPalette
    let typography: Typography
    let spacing: SpacingScale
    let cornerRadius: CornerRadiusScale
    let shadow: ShadowScale
    let layout: LayoutConstants
}

// MARK: - Default Instance (Friendly/Soft)

extension DesignSystem {
    static let `default` = DesignSystem(
        name: "Tweakable",
        colors: .default,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Sage Kitchen (Mediterranean Herb Garden & Terracotta)

    static let sageKitchen = DesignSystem(
        name: "Sage Kitchen",
        colors: .sageKitchen,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Midnight Bistro (Deep Navy & Deep Teal)

    static let midnightBistro = DesignSystem(
        name: "Midnight Bistro",
        colors: .midnightBistro,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Sunset Market (Coral & Teal)

    static let sunsetMarket = DesignSystem(
        name: "Sunset Market",
        colors: .sunsetMarket,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Zen Garden (Matcha & Charcoal)

    static let zenGarden = DesignSystem(
        name: "Zen Garden",
        colors: .zenGarden,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Spice Route (Turmeric & Indigo)

    static let spiceRoute = DesignSystem(
        name: "Spice Route",
        colors: .spiceRoute,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Citrus Pop (Vibrant Orange & Electric Lime)

    static let citrusPop = DesignSystem(
        name: "Citrus Pop",
        colors: .citrusPop,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Berry Blast (Hot Pink & Electric Purple)

    static let berryBlast = DesignSystem(
        name: "Berry Blast",
        colors: .berryBlast,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Tropical Punch (Mango Yellow & Ocean Blue)

    static let tropicalPunch = DesignSystem(
        name: "Tropical Punch",
        colors: .tropicalPunch,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )

    // MARK: - Garden Fresh (Leaf Green & Tomato Red)

    static let gardenFresh = DesignSystem(
        name: "Garden Fresh",
        colors: .gardenFresh,
        typography: .default,
        spacing: .default,
        cornerRadius: .default,
        shadow: .default,
        layout: .default
    )
}

// MARK: - Preview

private struct DesignSystemPreview: View {
    let theme: DesignSystem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                // Theme Name
                Text(theme.name)
                    .font(theme.typography.displayLarge.font)
                    .foregroundColor(theme.colors.textPrimary.color)

                // Colors Section
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Colors")
                        .font(theme.typography.headlineLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: theme.spacing.sm) {
                        ColorSwatch(adaptiveColor: theme.colors.primaryBrand, label: "Primary")
                        ColorSwatch(adaptiveColor: theme.colors.secondaryBrand, label: "Secondary")
                        ColorSwatch(adaptiveColor: theme.colors.success, label: "Success")
                        ColorSwatch(adaptiveColor: theme.colors.warning, label: "Warning")
                        ColorSwatch(adaptiveColor: theme.colors.error, label: "Error")
                    }

                    Text("Backgrounds")
                        .font(theme.typography.headlineSmall.font)
                        .foregroundColor(theme.colors.textSecondary.color)
                        .padding(.top, theme.spacing.xs)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: theme.spacing.sm) {
                        ColorSwatch(adaptiveColor: theme.colors.backgroundPrimary, label: "BG Primary", showBorder: true)
                        ColorSwatch(adaptiveColor: theme.colors.backgroundSecondary, label: "BG Secondary", showBorder: true)
                        ColorSwatch(adaptiveColor: theme.colors.backgroundTertiary, label: "BG Tertiary", showBorder: true)
                    }
                }

                // Typography Section
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    Text("Typography")
                        .font(theme.typography.headlineLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    TypographySample(label: "Display Large", style: theme.typography.displayLarge, sampleText: "送迎予定", textColor: theme.colors.textPrimary.color)
                    TypographySample(label: "Headline Large", style: theme.typography.headlineLarge, sampleText: "今日の担当", textColor: theme.colors.textPrimary.color)
                    TypographySample(label: "Body Large", style: theme.typography.bodyLarge, sampleText: "パパが送り、ママがお迎え", textColor: theme.colors.textSecondary.color)
                    TypographySample(label: "Caption Small", style: theme.typography.captionSmall, sampleText: "8:30 登園", textColor: theme.colors.textTertiary.color)
                }

                // Buttons Section
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Buttons")
                        .font(theme.typography.headlineLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    Button("担当を確定する") {}
                        .buttonStyle(PrimaryButtonStyle(theme: theme))

                    Button("変更をリクエスト") {}
                        .buttonStyle(SecondaryButtonStyle(theme: theme))
                }

                // Corner Radius Section
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Corner Radius")
                        .font(theme.typography.headlineLarge.font)
                        .foregroundColor(theme.colors.textPrimary.color)

                    HStack(spacing: theme.spacing.md) {
                        RoundedRectangle(cornerRadius: theme.cornerRadius.xs)
                            .fill(theme.colors.primaryBrand.color)
                            .frame(width: 50, height: 50)
                        RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                            .fill(theme.colors.primaryBrand.color)
                            .frame(width: 50, height: 50)
                        RoundedRectangle(cornerRadius: theme.cornerRadius.md)
                            .fill(theme.colors.primaryBrand.color)
                            .frame(width: 50, height: 50)
                        RoundedRectangle(cornerRadius: theme.cornerRadius.lg)
                            .fill(theme.colors.primaryBrand.color)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.backgroundPrimary.color)
    }
}

private struct ColorSwatch: View {
    let adaptiveColor: AdaptiveColor
    let label: String
    var showBorder: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(adaptiveColor.color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(showBorder ? 0.3 : 0), lineWidth: 1)
                )
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(adaptiveColor.hex)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

private struct TypographySample: View {
    let label: String
    let style: FontStyle
    let sampleText: String
    let textColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(label): \(sampleText)")
                .font(style.font)
                .foregroundColor(textColor)
            Text(style.description)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

struct DesignSystem_Previews: PreviewProvider {
    static var themes: [DesignSystem] = [
        .default,
        .sageKitchen,
        .midnightBistro,
        .sunsetMarket,
        .zenGarden,
        .spiceRoute,
        .citrusPop,
        .berryBlast,
        .tropicalPunch,
        .gardenFresh
    ]

    static var previews: some View {
        ForEach(themes, id: \.name) { theme in
            DesignSystemPreview(theme: theme)
                .preferredColorScheme(.light)
                .previewDisplayName("\(theme.name) - Light")

            DesignSystemPreview(theme: theme)
                .preferredColorScheme(.dark)
                .previewDisplayName("\(theme.name) - Dark")
        }
    }
}
