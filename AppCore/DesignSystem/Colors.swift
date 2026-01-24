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

// MARK: - Default Instance (Warm Pastel Peach/Orange)

extension ColorPalette {
    static let `default` = ColorPalette(
        // Brand - Pastel Peach/Orange & Forest Green
        primaryBrand: AdaptiveColor(light: "E8AA8C", dark: "D99B7D"),
        secondaryBrand: AdaptiveColor(light: "5A9E6F", dark: "6DB380"),

        // Background - Warm cream & soft peach tones
        backgroundPrimary: AdaptiveColor(light: "FFFAF6", dark: "2A2520"),
        backgroundSecondary: AdaptiveColor(light: "FFF5ED", dark: "36302A"),
        backgroundTertiary: AdaptiveColor(light: "FFEFE5", dark: "423B34"),

        // Text - Warm brown tones instead of pure black
        textPrimary: AdaptiveColor(light: "4A403A", dark: "FFF7F3"),
        textSecondary: AdaptiveColor(light: "6B5F56", dark: "D4C8C1"),
        textTertiary: AdaptiveColor(light: "9A8C82", dark: "A89890"),

        // Semantic - Stronger colors for better contrast
        success: AdaptiveColor(light: "5A9E6F", dark: "6DB380"),
        warning: AdaptiveColor(light: "D4A24C", dark: "E0B25E"),
        error: AdaptiveColor(light: "C75D5D", dark: "D46B6B"),
        info: AdaptiveColor(light: "5A8FB8", dark: "6DA3CC"),

        // Border & Separator - Warm tones
        separator: AdaptiveColor(light: "F0E0D6", dark: "4A403A"),
        border: AdaptiveColor(light: "E8D4C8", dark: "5A4E45")
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
