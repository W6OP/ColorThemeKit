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
  case none
  case skyNest = "skynest"
  case skyNestLite = "skynestLite"
  case sunrise
  case ocean
  case forest
  case graphite
  case natural
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
    case .none:
      "No Background"
    case .skyNest:
      "SkyNest Default"
    case .skyNestLite:
      "SkyNest Lite"
    case .sunrise:
      "Sunrise"
    case .ocean:
      "Ocean"
    case .forest:
      "Forest"
    case .graphite:
      "Graphite"
    case .natural:
      "Natural"
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

  /// Looks up a theme from an app-persisted raw value, including older package
  /// values that used camel-case raw strings.
  public static func theme(forStoredRawValue rawValue: String) -> GradientTheme?
  {
    if let theme = GradientTheme(rawValue: rawValue) {
      return theme
    }

    switch rawValue {
    case "skyNest":
      return .skyNest
    case "skyNestLite":
      return .skyNestLite
    default:
      return nil
    }
  }

  /// The gradient's stop colors, resolved for the given color scheme.
  ///
  /// Several themes provide distinct light and dark palettes; the rest are
  /// scheme-agnostic.
  public func colors(for scheme: ColorScheme) -> [Color] {
    switch self {
    case .none:
      [.clear, .clear]
    case .skyNest:
      switch scheme {
      case .light:
        [
          .themeRGB(0.29, 0.31, 0.75, 0.70),
          .themeRGB(0.00, 0.48, 1.00, 0.55),
          .themeRGB(0.69, 0.32, 0.87, 0.45),
        ]
      case .dark:
        [
          .themeRGB(0.18, 0.22, 0.32),
          .themeRGB(0.12, 0.18, 0.30),
          .themeRGB(0.16, 0.20, 0.32),
        ]
      @unknown default:
        [
          .themeRGB(0.29, 0.31, 0.75, 0.70),
          .themeRGB(0.00, 0.48, 1.00, 0.55),
          .themeRGB(0.69, 0.32, 0.87, 0.45),
        ]
      }
    case .skyNestLite:
      switch scheme {
      case .light:
        [
          .themeRGB(0.29, 0.31, 0.75, 0.28),
          .themeRGB(0.00, 0.48, 1.00, 0.22),
          .themeRGB(0.69, 0.32, 0.87, 0.16),
        ]
      case .dark:
        [
          .themeRGB(0.20, 0.24, 0.34),
          .themeRGB(0.16, 0.22, 0.32),
          .themeRGB(0.18, 0.24, 0.34),
        ]
      @unknown default:
        [
          .themeRGB(0.29, 0.31, 0.75, 0.28),
          .themeRGB(0.00, 0.48, 1.00, 0.22),
          .themeRGB(0.69, 0.32, 0.87, 0.16),
        ]
      }
    case .sunrise:
      scheme == .dark
        ? [
          .themeRGB(0.38, 0.18, 0.40, 0.95),
          .themeRGB(0.28, 0.18, 0.45, 0.90),
          .themeRGB(0.10, 0.10, 0.25, 0.95),
        ]
        : [
          .themeRGB(1.00, 0.82, 0.58, 0.85),
          .themeRGB(0.99, 0.76, 0.50, 0.75),
          .themeRGB(0.97, 0.80, 0.62, 0.65),
        ]
    case .ocean:
      scheme == .dark
        ? [
          .themeRGB(0.06, 0.14, 0.25, 0.95),
          .themeRGB(0.05, 0.24, 0.32, 0.95),
          .themeRGB(0.04, 0.20, 0.30, 0.95),
        ]
        : [
          .themeRGB(0.65, 0.85, 1.00, 1.00),
          .themeRGB(0.35, 0.73, 0.93, 0.90),
          .themeRGB(0.30, 0.60, 0.90, 0.80),
        ]
    case .forest:
      scheme == .dark
        ? [
          .themeRGB(0.07, 0.16, 0.10, 0.95),
          .themeRGB(0.05, 0.20, 0.15, 0.95),
          .themeRGB(0.04, 0.18, 0.16, 0.95),
        ]
        : [
          .themeRGB(0.76, 0.90, 0.78, 1.00),
          .themeRGB(0.52, 0.78, 0.70, 0.92),
          .themeRGB(0.40, 0.65, 0.65, 0.85),
        ]
    case .graphite:
      scheme == .dark
        ? [
          .themeRGB(0.10, 0.10, 0.12),
          .themeRGB(0.12, 0.13, 0.16),
          .themeRGB(0.16, 0.17, 0.20),
        ]
        : [
          .themeRGB(0.90, 0.92, 0.95),
          .themeRGB(0.82, 0.84, 0.88),
          .themeRGB(0.76, 0.78, 0.82),
        ]
    case .natural:
      scheme == .dark
        ? [.themeRGB(0, 0, 0), .themeRGB(0.11, 0.11, 0.118)]
        : [.themeRGB(1, 1, 1), .themeRGB(0.949, 0.949, 0.969)]
    case .glacier:
      scheme == .dark
        ? [
          .themeRGB(0.23, 0.31, 0.66),
          .themeRGB(0.24, 0.75, 0.86),
          .themeRGB(0.46, 0.21, 0.71),
        ]
        : [
          .themeRGB(0.58, 0.93, 0.84),
          .themeRGB(0.20, 0.82, 0.92),
          .themeRGB(0.00, 0.48, 1.00),
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
        .themeRGB(0.35, 0.34, 0.84), .themeRGB(0.69, 0.32, 0.87),
        .themeRGB(0.00, 0.48, 1.00),
        .themeRGB(0.20, 0.82, 0.92), .themeRGB(0.00, 0.50, 0.50),
        .themeRGB(0.35, 0.34, 0.84),
        .themeRGB(0.00, 0.48, 1.00), .themeRGB(0.20, 0.82, 0.92),
        .themeRGB(0.20, 0.82, 0.92),
      ]
    } else {
      [
        .themeRGB(0.58, 0.93, 0.84), .themeRGB(0.20, 0.82, 0.92),
        .themeRGB(0.00, 0.48, 1.00),
        .themeRGB(0.00, 0.50, 0.50), .themeRGB(0.69, 0.32, 0.87),
        .themeRGB(0.29, 0.31, 0.75),
        .themeRGB(0.20, 0.82, 0.92), .themeRGB(0.00, 0.48, 1.00),
        .themeRGB(0.58, 0.93, 0.84),
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
  static func themeRGB(
    _ red: Double,
    _ green: Double,
    _ blue: Double,
    _ opacity: Double = 1
  ) -> Color {
    Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
