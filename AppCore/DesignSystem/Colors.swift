import SwiftUI

// MARK: - Adaptive Color (light/dark hex pair)

struct AdaptiveColor {
    let lightHex: String
    let darkHex: String

    var color: Color {
        Color(light: Color(hex: lightHex), dark: Color(hex: darkHex))
    }

    var hex: String { "#\(lightHex.uppercased())" }

    init(light: String, dark: String) {
        self.lightHex = light
        self.darkHex = dark
    }

    init(hex: String) {
        self.lightHex = hex
        self.darkHex = hex
    }
}

// MARK: - Color Palette

struct ColorPalette {
    // Brand
    let primaryBrand: AdaptiveColor
    let secondaryBrand: AdaptiveColor

    // Background
    let backgroundPrimary: AdaptiveColor
    let backgroundSecondary: AdaptiveColor
    let backgroundTertiary: AdaptiveColor

    // Text
    let textPrimary: AdaptiveColor
    let textSecondary: AdaptiveColor
    let textTertiary: AdaptiveColor

    // Semantic
    let success: AdaptiveColor
    let warning: AdaptiveColor
    let error: AdaptiveColor
    let info: AdaptiveColor

    // Border & Separator
    let separator: AdaptiveColor
    let border: AdaptiveColor
}

// MARK: - Default Instance

extension ColorPalette {
    static let `default`: ColorPalette = .midnightBistro

    // MARK: - Sage Kitchen (Mediterranean Herb Garden & Terracotta)

    static let sageKitchen = ColorPalette(
        // Brand - Sage Green & Terracotta
        primaryBrand: AdaptiveColor(light: "8B9A7C", dark: "9DAD8E"),
        secondaryBrand: AdaptiveColor(light: "C4785C", dark: "D08A6E"),

        // Background - Off-white with warm undertones
        backgroundPrimary: AdaptiveColor(light: "FAF8F5", dark: "252420"),
        backgroundSecondary: AdaptiveColor(light: "F5F2ED", dark: "302D28"),
        backgroundTertiary: AdaptiveColor(light: "EFEBE4", dark: "3B3732"),

        // Text - Charcoal brown tones
        textPrimary: AdaptiveColor(light: "3D3B35", dark: "F5F3EE"),
        textSecondary: AdaptiveColor(light: "5C5950", dark: "D0CCC4"),
        textTertiary: AdaptiveColor(light: "8A857A", dark: "A5A098"),

        // Semantic
        success: AdaptiveColor(light: "6B8E6B", dark: "7CA07C"),
        warning: AdaptiveColor(light: "C4985C", dark: "D4A86C"),
        error: AdaptiveColor(light: "B85C5C", dark: "C86C6C"),
        info: AdaptiveColor(light: "5C8BA0", dark: "6C9BB0"),

        // Border & Separator
        separator: AdaptiveColor(light: "E8E4DC", dark: "3D3B35"),
        border: AdaptiveColor(light: "DCD6CC", dark: "4A4640")
    )

    // MARK: - Midnight Bistro (Deep Navy & Deep Teal)

    static let midnightBistro = ColorPalette(
        // Brand - Deep Navy & Deep Teal
        primaryBrand: AdaptiveColor(light: "2C3E50", dark: "3D5266"),
        secondaryBrand: AdaptiveColor(light: "2A7B7B", dark: "3A8F8F"),

        // Background - Cool white / dark slate
        backgroundPrimary: AdaptiveColor(light: "FAFBFC", dark: "1A1D21"),
        backgroundSecondary: AdaptiveColor(light: "F4F6F8", dark: "24282E"),
        backgroundTertiary: AdaptiveColor(light: "EBEEF2", dark: "2E333A"),

        // Text - Navy tones
        textPrimary: AdaptiveColor(light: "2C3E50", dark: "E8ECF0"),
        textSecondary: AdaptiveColor(light: "4A5568", dark: "B8C2CC"),
        textTertiary: AdaptiveColor(light: "718096", dark: "8A96A4"),

        // Semantic
        success: AdaptiveColor(light: "48825C", dark: "5A9470"),
        warning: AdaptiveColor(light: "C9A962", dark: "D4B872"),
        error: AdaptiveColor(light: "A85454", dark: "B86666"),
        info: AdaptiveColor(light: "4A7C9B", dark: "5C8EAD"),

        // Border & Separator
        separator: AdaptiveColor(light: "E2E6EC", dark: "2C3E50"),
        border: AdaptiveColor(light: "CBD5E0", dark: "3D5266")
    )

    // MARK: - Sunset Market (Coral & Teal)

    static let sunsetMarket = ColorPalette(
        // Brand - Coral Pink & Teal Green
        primaryBrand: AdaptiveColor(light: "E07A5F", dark: "E88B72"),
        secondaryBrand: AdaptiveColor(light: "5E8B7E", dark: "72A091"),

        // Background - Warm white
        backgroundPrimary: AdaptiveColor(light: "FDF8F6", dark: "262220"),
        backgroundSecondary: AdaptiveColor(light: "F8F2EF", dark: "312C28"),
        backgroundTertiary: AdaptiveColor(light: "F2EBE6", dark: "3C3632"),

        // Text - Dark brown tones
        textPrimary: AdaptiveColor(light: "3D3835", dark: "F8F4F2"),
        textSecondary: AdaptiveColor(light: "5C5552", dark: "D4CFCC"),
        textTertiary: AdaptiveColor(light: "8A8280", dark: "A8A2A0"),

        // Semantic
        success: AdaptiveColor(light: "5E8B7E", dark: "72A091"),
        warning: AdaptiveColor(light: "D4A05C", dark: "E0B06C"),
        error: AdaptiveColor(light: "C75A5A", dark: "D66C6C"),
        info: AdaptiveColor(light: "5A8BA0", dark: "6C9DB2"),

        // Border & Separator
        separator: AdaptiveColor(light: "EBE2DC", dark: "3D3835"),
        border: AdaptiveColor(light: "DED4CC", dark: "4A4440")
    )

    // MARK: - Zen Garden (Matcha & Charcoal)

    static let zenGarden = ColorPalette(
        // Brand - Matcha Green & Charcoal
        primaryBrand: AdaptiveColor(light: "6B8E6B", dark: "7CA07C"),
        secondaryBrand: AdaptiveColor(light: "5C5C5C", dark: "787878"),

        // Background - Natural off-white / dark charcoal
        backgroundPrimary: AdaptiveColor(light: "F9F9F7", dark: "1E1E1C"),
        backgroundSecondary: AdaptiveColor(light: "F3F3F0", dark: "282826"),
        backgroundTertiary: AdaptiveColor(light: "ECECE8", dark: "323230"),

        // Text - Ink/sumi tones
        textPrimary: AdaptiveColor(light: "333330", dark: "EAEAE5"),
        textSecondary: AdaptiveColor(light: "52524E", dark: "C8C8C2"),
        textTertiary: AdaptiveColor(light: "7A7A74", dark: "9A9A94"),

        // Semantic
        success: AdaptiveColor(light: "6B8E6B", dark: "7CA07C"),
        warning: AdaptiveColor(light: "B8A060", dark: "C8B070"),
        error: AdaptiveColor(light: "A05050", dark: "B06262"),
        info: AdaptiveColor(light: "5080A0", dark: "6292B2"),

        // Border & Separator
        separator: AdaptiveColor(light: "E5E5E0", dark: "333330"),
        border: AdaptiveColor(light: "D8D8D2", dark: "424240")
    )

    // MARK: - Spice Route (Turmeric & Indigo)

    static let spiceRoute = ColorPalette(
        // Brand - Turmeric Yellow & Indigo Gray
        primaryBrand: AdaptiveColor(light: "D4A03D", dark: "E0AE4F"),
        secondaryBrand: AdaptiveColor(light: "4A5568", dark: "5D6B7E"),

        // Background - Ivory / dark olive
        backgroundPrimary: AdaptiveColor(light: "FFFDF8", dark: "252318"),
        backgroundSecondary: AdaptiveColor(light: "FAF7F0", dark: "302C22"),
        backgroundTertiary: AdaptiveColor(light: "F4F0E6", dark: "3B362C"),

        // Text - Dark olive tones
        textPrimary: AdaptiveColor(light: "2D2A20", dark: "FAF8F0"),
        textSecondary: AdaptiveColor(light: "4A4638", dark: "D4D0C4"),
        textTertiary: AdaptiveColor(light: "7A7464", dark: "A8A498"),

        // Semantic
        success: AdaptiveColor(light: "5A8A5A", dark: "6C9C6C"),
        warning: AdaptiveColor(light: "D4A03D", dark: "E0AE4F"),
        error: AdaptiveColor(light: "B85050", dark: "C86262"),
        info: AdaptiveColor(light: "4A5568", dark: "5D6B7E"),

        // Border & Separator
        separator: AdaptiveColor(light: "EAE6DA", dark: "2D2A20"),
        border: AdaptiveColor(light: "DCD6C8", dark: "3D3830")
    )

    // MARK: - Citrus Pop (Vibrant Orange & Electric Lime)

    static let citrusPop = ColorPalette(
        // Brand - Vivid Orange & Electric Lime
        primaryBrand: AdaptiveColor(light: "FF6B35", dark: "FF7D4D"),
        secondaryBrand: AdaptiveColor(light: "7CB518", dark: "8EC72A"),

        // Background - Clean white with warm tint
        backgroundPrimary: AdaptiveColor(light: "FFFEFA", dark: "1F1E1A"),
        backgroundSecondary: AdaptiveColor(light: "FFF8F0", dark: "2A2820"),
        backgroundTertiary: AdaptiveColor(light: "FFF0E0", dark: "353228"),

        // Text - Deep charcoal
        textPrimary: AdaptiveColor(light: "2D2926", dark: "FFF8F2"),
        textSecondary: AdaptiveColor(light: "4A4540", dark: "D8D2CA"),
        textTertiary: AdaptiveColor(light: "787068", dark: "A8A298"),

        // Semantic
        success: AdaptiveColor(light: "2CB52C", dark: "40C940"),
        warning: AdaptiveColor(light: "FFB300", dark: "FFC020"),
        error: AdaptiveColor(light: "E53935", dark: "EF5350"),
        info: AdaptiveColor(light: "039BE5", dark: "29B6F6"),

        // Border & Separator
        separator: AdaptiveColor(light: "F0E8D8", dark: "2D2926"),
        border: AdaptiveColor(light: "E8DCC8", dark: "3D3830")
    )

    // MARK: - Berry Blast (Hot Pink & Electric Purple)

    static let berryBlast = ColorPalette(
        // Brand - Hot Pink & Electric Purple
        primaryBrand: AdaptiveColor(light: "E91E63", dark: "F06292"),
        secondaryBrand: AdaptiveColor(light: "7C4DFF", dark: "9575FF"),

        // Background - Subtle warm white / deep purple-black
        backgroundPrimary: AdaptiveColor(light: "FFFBFC", dark: "1A181C"),
        backgroundSecondary: AdaptiveColor(light: "FFF5F7", dark: "252228"),
        backgroundTertiary: AdaptiveColor(light: "FFECF0", dark: "302C34"),

        // Text - Deep purple-gray
        textPrimary: AdaptiveColor(light: "2E2532", dark: "FAF5F8"),
        textSecondary: AdaptiveColor(light: "524558", dark: "D4C8D0"),
        textTertiary: AdaptiveColor(light: "7A6B80", dark: "A898A8"),

        // Semantic
        success: AdaptiveColor(light: "00C853", dark: "00E676"),
        warning: AdaptiveColor(light: "FF9100", dark: "FFAB40"),
        error: AdaptiveColor(light: "FF1744", dark: "FF5252"),
        info: AdaptiveColor(light: "00B0FF", dark: "40C4FF"),

        // Border & Separator
        separator: AdaptiveColor(light: "F0E4E8", dark: "2E2532"),
        border: AdaptiveColor(light: "E4D4DC", dark: "3E3442")
    )

    // MARK: - Tropical Punch (Mango Yellow & Ocean Blue)

    static let tropicalPunch = ColorPalette(
        // Brand - Mango Yellow & Ocean Blue
        primaryBrand: AdaptiveColor(light: "FFB627", dark: "FFC547"),
        secondaryBrand: AdaptiveColor(light: "00A8E8", dark: "20C0F8"),

        // Background - Bright clean white
        backgroundPrimary: AdaptiveColor(light: "FFFFFE", dark: "181C20"),
        backgroundSecondary: AdaptiveColor(light: "FFF9F0", dark: "22282E"),
        backgroundTertiary: AdaptiveColor(light: "FFF2E0", dark: "2C3238"),

        // Text - Deep blue-gray
        textPrimary: AdaptiveColor(light: "1A2530", dark: "F8FCFF"),
        textSecondary: AdaptiveColor(light: "3A4858", dark: "C8D4E0"),
        textTertiary: AdaptiveColor(light: "607080", dark: "98A8B8"),

        // Semantic
        success: AdaptiveColor(light: "00C48C", dark: "00D89E"),
        warning: AdaptiveColor(light: "FFB627", dark: "FFC547"),
        error: AdaptiveColor(light: "FF4757", dark: "FF6B7A"),
        info: AdaptiveColor(light: "00A8E8", dark: "20C0F8"),

        // Border & Separator
        separator: AdaptiveColor(light: "E8ECF0", dark: "1A2530"),
        border: AdaptiveColor(light: "D4DCE4", dark: "2A3540")
    )

    // MARK: - Garden Fresh (Leaf Green & Tomato Red)

    static let gardenFresh = ColorPalette(
        // Brand - Vibrant Leaf Green & Tomato Red
        primaryBrand: AdaptiveColor(light: "4CAF50", dark: "66C96A"),
        secondaryBrand: AdaptiveColor(light: "E53935", dark: "EF5350"),

        // Background - Fresh clean white
        backgroundPrimary: AdaptiveColor(light: "FCFFF8", dark: "1A1E18"),
        backgroundSecondary: AdaptiveColor(light: "F4FAF0", dark: "242A20"),
        backgroundTertiary: AdaptiveColor(light: "E8F4E0", dark: "2E3628"),

        // Text - Deep forest
        textPrimary: AdaptiveColor(light: "1E2A1E", dark: "F2FAF0"),
        textSecondary: AdaptiveColor(light: "3A4A3A", dark: "C4D4C2"),
        textTertiary: AdaptiveColor(light: "607060", dark: "98A898"),

        // Semantic
        success: AdaptiveColor(light: "4CAF50", dark: "66C96A"),
        warning: AdaptiveColor(light: "FFC107", dark: "FFD54F"),
        error: AdaptiveColor(light: "E53935", dark: "EF5350"),
        info: AdaptiveColor(light: "2196F3", dark: "42A5F5"),

        // Border & Separator
        separator: AdaptiveColor(light: "DCE8D8", dark: "1E2A1E"),
        border: AdaptiveColor(light: "C8DCC4", dark: "2A3A28")
    )
}

// MARK: - Color Utilities

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
