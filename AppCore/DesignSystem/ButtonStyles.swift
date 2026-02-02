import SwiftUI

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    let theme: DesignSystem
    @Environment(\.isEnabled) private var isEnabled

    init(theme: DesignSystem = .default) {
        self.theme = theme
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.buttonLarge.font)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                    .fill(isEnabled ? theme.colors.primaryBrand.color : theme.colors.primaryBrand.color.opacity(0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(configuration.isPressed ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    let theme: DesignSystem
    @Environment(\.isEnabled) private var isEnabled

    init(theme: DesignSystem = .default) {
        self.theme = theme
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.buttonLarge.font)
            .foregroundColor(isEnabled ? theme.colors.primaryBrand.color : theme.colors.primaryBrand.color.opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                    .fill(configuration.isPressed ? theme.colors.primaryBrand.color.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                    .stroke(isEnabled ? theme.colors.primaryBrand.color : theme.colors.primaryBrand.color.opacity(0.5), lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: theme.cornerRadius.sm))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(configuration.isPressed ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style

struct TertiaryButtonStyle: ButtonStyle {
    let theme: DesignSystem
    @Environment(\.isEnabled) private var isEnabled

    init(theme: DesignSystem = .default) {
        self.theme = theme
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.buttonMedium.font)
            .foregroundColor(isEnabled ? theme.colors.primaryBrand.color : theme.colors.primaryBrand.color.opacity(0.5))
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.xs)
                    .fill(configuration.isPressed ? theme.colors.primaryBrand.color.opacity(0.15) : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: theme.cornerRadius.xs))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(configuration.isPressed ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Filled Secondary Button Style

struct FilledSecondaryButtonStyle: ButtonStyle {
    let theme: DesignSystem
    @Environment(\.isEnabled) private var isEnabled

    init(theme: DesignSystem = .default) {
        self.theme = theme
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.buttonLarge.font)
            .foregroundColor(isEnabled ? theme.colors.textPrimary.color : theme.colors.textPrimary.color.opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                    .fill(isEnabled ? theme.colors.backgroundSecondary.color : theme.colors.backgroundSecondary.color.opacity(0.5))
            )
            .contentShape(RoundedRectangle(cornerRadius: theme.cornerRadius.sm))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(configuration.isPressed ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style

struct DestructiveButtonStyle: ButtonStyle {
    let theme: DesignSystem
    @Environment(\.isEnabled) private var isEnabled

    init(theme: DesignSystem = .default) {
        self.theme = theme
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.buttonLarge.font)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius.sm)
                    .fill(isEnabled ? theme.colors.error.color : theme.colors.error.color.opacity(0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(configuration.isPressed ? .none : .spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
