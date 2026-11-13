import SwiftUI

public extension GradientTheme {
    /// Estimated worst-case text contrast over this theme as drawn by
    /// `themedBackground(_:frosted:)`, including Glacier's mesh colors.
    ///
    /// Regular material uses an estimated 0.6-opacity scrim; thin material uses
    /// 0.4. Apple does not publish material opacity, so these are estimates,
    /// not accessibility guarantees. Text and system surfaces are approximated.
    /// Increase Contrast suppresses the gradient in the modifier; callers may
    /// skip warnings then. This function does not read accessibility settings.
    func estimatedContrast(in scheme: ColorScheme, frosted: Bool = true) -> ThemeContrast.Ratios {
        ThemeContrast.estimate(self, in: scheme, frosted: frosted)
    }

    /// Whether estimated primary or secondary contrast is below the thresholds.
    ///
    /// `none` is never flagged. When Increase Contrast is enabled, the background
    /// modifier omits the gradient and apps may skip this warning.
    func isLowContrast(in scheme: ColorScheme, frosted: Bool = true) -> Bool {
        guard self != .none else { return false }
        let ratios = estimatedContrast(in: scheme, frosted: frosted)
        return ratios.primary < ThemeContrast.minimumPrimaryRatio
            || ratios.secondary < ThemeContrast.minimumSecondaryRatio
    }
}

/// Pure, nonisolated contrast estimation using gamma-encoded sRGB components.
/// No UIKit, AppKit, or accessibility settings are consulted.
public enum ThemeContrast {
    /// A gamma-encoded sRGB color with finite components in `0...1`.
    public struct RGB: Equatable, Sendable {
        /// Red component.
        public let red: Double
        /// Green component.
        public let green: Double
        /// Blue component.
        public let blue: Double

        /// Creates a color. Components must be finite and in `0...1`.
        public init(red: Double, green: Double, blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }

        /// Opaque white.
        public static let white = RGB(red: 1, green: 1, blue: 1)
        /// Opaque black.
        public static let black = RGB(red: 0, green: 0, blue: 0)
    }

    /// Lowest estimated contrast ratios across the theme's sampled colors.
    public struct Ratios: Equatable, Sendable {
        /// Contrast of approximated system primary text.
        public let primary: Double
        /// Contrast of approximated system secondary text.
        public let secondary: Double

        /// Creates a pair of contrast ratios.
        public init(primary: Double, secondary: Double) {
            self.primary = primary
            self.secondary = secondary
        }
    }

    /// Primary text below the WCAG AAA threshold is flagged.
    public static let minimumPrimaryRatio = 7.0
    /// Secondary text threshold, relative to the roughly 3.4:1 plain-light baseline.
    public static let minimumSecondaryRatio = 3.0

    /// WCAG 2 contrast ratio in `1...21` for valid sRGB components.
    public static func contrastRatio(_ first: RGB, _ second: RGB) -> Double {
        let lhs = relativeLuminance(first)
        let rhs = relativeLuminance(second)
        return (max(lhs, rhs) + 0.05) / (min(lhs, rhs) + 0.05)
    }

    /// WCAG 2 relative luminance of a gamma-encoded sRGB color.
    public static func relativeLuminance(_ color: RGB) -> Double {
        func linear(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(color.red) + 0.7152 * linear(color.green) + 0.0722 * linear(color.blue)
    }

    /// Source-over compositing in gamma-encoded sRGB for this estimate.
    /// The opacity must be finite and in `0...1`.
    public static func blend(_ top: RGB, opacity: Double, over bottom: RGB) -> RGB {
        RGB(
            red: top.red * opacity + bottom.red * (1 - opacity),
            green: top.green * opacity + bottom.green * (1 - opacity),
            blue: top.blue * opacity + bottom.blue * (1 - opacity)
        )
    }

    static func estimate(_ theme: GradientTheme, in scheme: ColorScheme, frosted: Bool) -> Ratios {
        let dark = scheme == .dark
        let background: RGB = dark ? .black : .white
        let primaryText: RGB = dark ? .white : .black
        let secondaryText = dark
            ? RGB(red: 0.922, green: 0.922, blue: 0.961)
            : RGB(red: 0.235, green: 0.235, blue: 0.263)
        let scrim = dark ? RGB(red: 0.12, green: 0.12, blue: 0.13) : RGB.white
        // Match GradientThemeBackground's mesh selection.
        let colors = theme == .glacier ? theme.meshColors(for: scheme) : theme.colors(for: scheme)
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        var primary = Double.infinity
        var secondary = Double.infinity
        for color in colors {
            let resolved = color.resolve(in: environment)
            func clamped(_ value: Float) -> Double { min(max(Double(value), 0), 1) }
            let stop = RGB(
                red: clamped(resolved.red),
                green: clamped(resolved.green),
                blue: clamped(resolved.blue)
            )
            let gradient = blend(stop, opacity: clamped(resolved.opacity), over: background)
            let surface = blend(scrim, opacity: frosted ? 0.6 : 0.4, over: gradient)
            let greyText = blend(secondaryText, opacity: 0.6, over: surface)
            primary = min(primary, contrastRatio(primaryText, surface))
            secondary = min(secondary, contrastRatio(greyText, surface))
        }
        return Ratios(primary: primary, secondary: secondary)
    }
}
