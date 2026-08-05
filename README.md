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

## License

ColorThemeKit is available under the MIT license. See the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 Peter Bourget
