import SwiftUI

/// Reusable gradient themes for app-level styling.
///
/// Each theme exposes a ``displayName`` for menus, a set of stop ``colors(for:)``
/// resolved for a given `ColorScheme`, and a ready-made ``gradient`` view that
/// adapts automatically to the current color scheme.
///
/// The color values are expressed as constant sRGB components so the themes render
/// identically on every platform (they do not rely on UIKit/AppKit system colors).
public enum GradientTheme: String, CaseIterable, Identifiable, Sendable {
    case natural
    case skyNest
    case glacier
    case lightBlueGreen
    case darkBlueGreen
    case lightBlueOrange
    case darkBlueOrange
    case lightRoseGold
    case darkSlateBerry

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .natural:
            "Natural"
        case .skyNest:
            "SkyNest"
        case .glacier:
            "Glacier"
        case .lightBlueGreen:
            "Light Blue Green"
        case .darkBlueGreen:
            "Dark Blue Green"
        case .lightBlueOrange:
            "Light Blue Orange"
        case .darkBlueOrange:
            "Dark Blue Orange"
        case .lightRoseGold:
            "Light Rose Gold"
        case .darkSlateBerry:
            "Dark Slate Berry"
        }
    }

    /// The gradient's stop colors, resolved for the given color scheme.
    ///
    /// Themes with distinct light and dark appearances (``natural``, ``skyNest``,
    /// ``glacier``) return different palettes per scheme; the rest are scheme-agnostic.
    public func colors(for scheme: ColorScheme) -> [Color] {
        switch self {
        case .natural:
            scheme == .dark
                ? [.themeRGB(0, 0, 0), .themeRGB(0.11, 0.11, 0.118)]
                : [.themeRGB(1, 1, 1), .themeRGB(0.949, 0.949, 0.969)]
        case .skyNest:
            scheme == .dark
                ? [
                    .themeRGB(0.20, 0.24, 0.34),
                    .themeRGB(0.16, 0.22, 0.32),
                    .themeRGB(0.18, 0.24, 0.34)
                ]
                : [
                    .themeRGB(0.29, 0.31, 0.75, 0.18),
                    .themeRGB(0.00, 0.48, 1.00, 0.14),
                    .themeRGB(0.69, 0.32, 0.87, 0.10)
                ]
        case .glacier:
            scheme == .dark
                ? [
                    .themeRGB(0.23, 0.31, 0.66),
                    .themeRGB(0.24, 0.75, 0.86),
                    .themeRGB(0.46, 0.21, 0.71)
                ]
                : [
                    .themeRGB(0.58, 0.93, 0.84),
                    .themeRGB(0.20, 0.82, 0.92),
                    .themeRGB(0.00, 0.48, 1.00)
                ]
        case .lightBlueGreen:
            [.themeRGB(0.77, 0.92, 0.98), .themeRGB(0.74, 0.95, 0.85)]
        case .darkBlueGreen:
            [.themeRGB(0.08, 0.29, 0.42), .themeRGB(0.10, 0.47, 0.34)]
        case .lightBlueOrange:
            [.themeRGB(0.78, 0.91, 1.0), .themeRGB(1.0, 0.83, 0.62)]
        case .darkBlueOrange:
            [.themeRGB(0.10, 0.24, 0.43), .themeRGB(0.78, 0.42, 0.17)]
        case .lightRoseGold:
            [.themeRGB(0.99, 0.92, 0.89), .themeRGB(0.95, 0.80, 0.73)]
        case .darkSlateBerry:
            [.themeRGB(0.13, 0.16, 0.24), .themeRGB(0.35, 0.18, 0.33)]
        }
    }

    /// The nine mesh-gradient colors used by ``glacier``, resolved for the scheme.
    func meshColors(for scheme: ColorScheme) -> [Color] {
        if scheme == .dark {
            [
                .themeRGB(0.35, 0.34, 0.84), .themeRGB(0.69, 0.32, 0.87), .themeRGB(0.00, 0.48, 1.00),
                .themeRGB(0.20, 0.82, 0.92), .themeRGB(0.00, 0.50, 0.50), .themeRGB(0.35, 0.34, 0.84),
                .themeRGB(0.00, 0.48, 1.00), .themeRGB(0.20, 0.82, 0.92), .themeRGB(0.20, 0.82, 0.92)
            ]
        } else {
            [
                .themeRGB(0.58, 0.93, 0.84), .themeRGB(0.20, 0.82, 0.92), .themeRGB(0.00, 0.48, 1.00),
                .themeRGB(0.00, 0.50, 0.50), .themeRGB(0.69, 0.32, 0.87), .themeRGB(0.29, 0.31, 0.75),
                .themeRGB(0.20, 0.82, 0.92), .themeRGB(0.00, 0.48, 1.00), .themeRGB(0.58, 0.93, 0.84)
            ]
        }
    }

    /// A view that draws this theme's gradient, adapting to the current color scheme.
    public var gradient: some View {
        GradientThemeBackground(theme: self)
    }
}

extension Color {
    /// Convenience sRGB constructor used by the theme color tables.
    static func themeRGB(_ red: Double, _ green: Double, _ blue: Double, _ opacity: Double = 1) -> Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
