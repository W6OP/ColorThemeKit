# ColorThemeKit

A small, cross-platform SwiftUI package providing reusable **gradient background themes** and **ARGB ↔︎ `Color`** conversion helpers.

The themes are defined entirely in constant sRGB components — no UIKit/AppKit dependency — so they render identically on every Apple platform and adapt automatically to light and dark mode.

## Features

- **`GradientTheme`** — nine ready-made gradient themes (linear and mesh), each with a display name suitable for menus.
- **Automatic light/dark adaptation** — themes read the environment's `colorScheme`; several provide distinct light and dark palettes.
- **Drop-in gradient view** — `theme.gradient` returns a `View` you can use directly as a `.background(...)`.
- **Accessibility-aware themed backgrounds** — `.themedBackground(_:frosted:)` paints a theme behind a `List`/`Form` with a material legibility scrim, and defers to the system when **Increase Contrast** is on.
- **`Color(argb:)` / `Color.toArgb()`** — pack and unpack a `Color` as a 32-bit `0xAARRGGBB` integer, handy for persisting user-selected colors. Uses the SwiftUI-native `Color.resolve(in:)` API.

## Requirements

| Platform  | Minimum |
| --------- | ------- |
| iOS       | 18.0    |
| macOS     | 15.0    |
| tvOS      | 18.0    |
| watchOS   | 11.0    |
| visionOS  | 2.0     |

Swift 6.0+ / Xcode 16+.

## Installation

### Swift Package Manager (remote)

Add the package to your project via **File → Add Package Dependencies…** in Xcode, or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/w6op/ColorThemeKit.git", from: "1.0.0")
]
```

Then add `"ColorThemeKit"` to your target's dependencies.

### Local package

In Xcode: **File → Add Package Dependencies… → Add Local…** and select the `ColorThemeKit` folder.

## Usage

Import the module wherever you need it:

```swift
import ColorThemeKit
```

### Gradient backgrounds

Use a theme's `gradient` view directly as a background. It fills the safe area and updates live when the user switches between light and dark mode:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .background(GradientTheme.skyNest.gradient)
    }
}
```

Persist the user's choice with `@AppStorage` using the theme's `rawValue`:

```swift
struct ThemedView: View {
    @AppStorage("selectedGradientTheme") private var themeID = GradientTheme.skyNest.rawValue

    private var theme: GradientTheme {
        GradientTheme(rawValue: themeID) ?? .skyNest
    }

    var body: some View {
        NavigationStack {
            List { /* ... */ }
                .background(theme.gradient)
                .toolbar {
                    Menu("Theme") {
                        ForEach(GradientTheme.allCases) { option in
                            Button(option.displayName) { themeID = option.rawValue }
                        }
                    }
                }
        }
    }
}
```

### Accessibility-aware themed backgrounds

For screens whose content is a `List` or `Form`, use `.themedBackground(_:frosted:)`. It draws the gradient behind the (transparent) scroll content with a material scrim so text keeps system-guaranteed contrast. When the user enables **Increase Contrast**, or picks `.none`, the decorative gradient is skipped and the system's opaque surfaces are used:

```swift
struct RootScreen: View {
    @AppStorage("selectedGradientTheme") private var themeID = GradientTheme.skyNestLite.rawValue
    @AppStorage("themedBackgroundFrosted") private var isFrosted = true

    var body: some View {
        List {
            // ...
        }
        .themedBackground(
            GradientTheme.theme(forStoredRawValue: themeID) ?? .skyNestLite,
            frosted: isFrosted
        )
    }
}
```

Pass `frosted: false` to use `.thinMaterial` (letting the gradient show through more vividly) instead of the default `.regularMaterial`.

### Accessing raw stop colors

If you need the individual gradient stops (for example, to build a matching scrim), ask for them by color scheme:

```swift
struct ScrimView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let stops = GradientTheme.glacier.colors(for: colorScheme)
        LinearGradient(
            colors: [.clear, stops.last ?? .white],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
```

### ARGB ↔︎ Color

```swift
// Build a Color from a packed 0xAARRGGBB integer.
let color = Color(argb: 0xFF3478F6)

// Pack a Color back into an integer (e.g. to store in a database).
let packed = color.toArgb()
```

The round-trip is lossless for standard sRGB colors — each channel is resolved in the sRGB color space and clamped to `0...255`.

## Available themes

| Case              | Display name       | Style  | Adapts to scheme |
| ----------------- | ------------------ | ------ | ---------------- |
| `none`            | No Background       | —      | —                |
| `skyNest`         | SkyNest Default     | Linear | Yes              |
| `skyNestLite`     | SkyNest Lite        | Linear | Yes              |
| `sunrise`         | Sunrise             | Linear | Yes              |
| `ocean`           | Ocean               | Linear | Yes              |
| `forest`          | Forest              | Linear | Yes              |
| `graphite`        | Graphite            | Linear | Yes              |
| `natural`         | Natural             | Linear | Yes              |
| `glacier`         | Glacier             | Mesh   | Yes              |
| `lightBlueGreen`  | Light Blue Green    | Linear | No               |
| `darkBlueGreen`   | Dark Blue Green     | Linear | No               |
| `lightBlueOrange` | Light Blue Orange   | Linear | No               |
| `darkBlueOrange`  | Dark Blue Orange    | Linear | No               |
| `lightRoseGold`   | Light Rose Gold     | Linear | No               |
| `darkSlateBerry`  | Dark Slate Berry    | Linear | No               |

## Checking contrast

```swift
let theme = GradientTheme.glacier
let ratios = theme.estimatedContrast(in: .dark) // regular material by default
let showWarning = theme.isLowContrast(in: .dark)
let thinWarning = theme.isLowContrast(in: .dark, frosted: false)
```

Pass the same color scheme and `frosted` value used by your background. The estimate
composites each stop over a white/light or black/dark background, then applies a
0.6-opacity scrim for regular material or 0.4 for thin material. Glacier uses its
nine mesh colors. Approximated primary and translucent secondary text are measured
with WCAG 2 contrast ratios; the lowest ratio for each is returned. A warning means
primary is below **7:1** or secondary below **3:1**. `.none` is never flagged.

Apple does not publish material opacity. These estimates preserve the original
Tickmark heuristic and are not an accessibility guarantee: actual materials,
interpolation between sampled colors, content, system settings, and platforms can
change contrast. In particular, the earlier material description's reference to
“system-guaranteed contrast” should not be interpreted as a guarantee. Increase
Contrast makes `themedBackground` skip the gradient, so apps may skip warnings then;
these pure functions do not read accessibility settings.

Generated from `estimatedContrast(in:)` with `frosted: true`; each cell shows
**primary / secondary** ratios followed by the warning result. `.none` ratios use
the same scrim model for consistency, although its actual background is undecorated.

| Theme | Light | Dark |
| --- | --- | --- |
| `none` | 21.00 / 3.44 — OK | 18.66 / 6.22 — OK |
| `skyNest` | 13.60 / 2.88 — Warning | 14.56 / 5.42 — OK |
| `skyNestLite` | 17.79 / 3.22 — OK | 14.16 / 5.33 — OK |
| `sunrise` | 18.29 / 3.26 — OK | 14.23 / 5.32 — OK |
| `ocean` | 15.23 / 3.03 — OK | 14.89 / 5.48 — OK |
| `forest` | 15.36 / 3.04 — OK | 15.74 / 5.68 — OK |
| `graphite` | 17.21 / 3.18 — OK | 15.55 / 5.65 — OK |
| `natural` | 20.11 / 3.38 — OK | 16.72 / 5.90 — OK |
| `glacier` | 11.05 / 2.63 — Warning | 6.51 / 3.06 — Warning |
| `lightBlueGreen` | 19.12 / 3.32 — OK | 5.06 / 2.60 — Warning |
| `darkBlueGreen` | 10.05 / 2.51 — Warning | 11.10 / 4.49 — OK |
| `lightBlueOrange` | 18.44 / 3.27 — OK | 5.15 / 2.63 — Warning |
| `darkBlueOrange` | 9.69 / 2.47 — Warning | 9.47 / 4.01 — OK |
| `lightRoseGold` | 18.01 / 3.24 — OK | 4.83 / 2.52 — Warning |
| `darkSlateBerry` | 8.96 / 2.38 — Warning | 14.28 / 5.34 — OK |

`ThemeContrast` also exposes `RGB`, `Ratios`, the thresholds, `blend`,
`relativeLuminance`, and `contrastRatio` for custom estimates. RGB components and
blend opacity must be finite values in `0...1`. The value types are `Sendable`,
and all estimation APIs are nonisolated.

## Release notes

### 1.2.0

- Added text contrast estimates and warnings, including Glacier's mesh palette
  and separate regular/thin material assumptions.
- Added contrast tests and generated light/dark results.
- Preserved all existing APIs, rendering, Swift tools version, and platform minimums.
- Removed tracked build artifacts and added Swift package ignore rules.
- Added a SwiftLint baseline for existing source issues, keeping new code lint-clean.
- Verified macOS build/tests and iOS, watchOS, and visionOS simulator builds.
  tvOS remains blocked by the existing `scrollContentBackground` call in
  `ThemedBackground.swift`, which is unavailable on tvOS.
- API comparison against v1.1.4 reports no breaking changes.

## License

ColorThemeKit is available under the MIT license. See the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 Peter Bourget
