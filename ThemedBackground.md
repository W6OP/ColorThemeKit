# Themed Background Modifier

A reusable, accessibility-aware way to paint a `GradientTheme` behind scrolling
content. This lifts the logic that previously lived per-app (in TravelLoom's
`AppTheme`) into `ColorThemeKit` so every consumer gets the same behavior — and
so accessibility improvements land in one place.

## Why this exists

Applying a saturated gradient directly behind a `List`/`Form` (via
`.scrollContentBackground(.hidden)`) puts system label colors straight on top of
the gradient. On vivid palettes (e.g. `glacier`, `darkBlueOrange`) this drops
text contrast below the WCAG 4.5:1 threshold — disqualifying an app from
honestly claiming the App Store **Sufficient Contrast** accessibility label.

This modifier fixes that by:

1. **Drawing a material scrim between the gradient and the content**, so text
   renders on a system-tuned surface (legible) while the gradient still tints
   through.
2. **Deferring to the system entirely when _Increase Contrast_ is on** — it
   skips the gradient so opaque high-contrast surfaces guarantee legibility.
3. **Doing nothing for `.none`**, preserving the plain system background.

## Add this file to ColorThemeKit

Create `Sources/ColorThemeKit/ThemedBackground.swift`:

```swift
import SwiftUI

public extension View {
    /// Paints `theme`'s gradient behind this view with an accessibility-aware
    /// legibility scrim.
    ///
    /// Intended for screens whose content is a `List` or `Form`. The gradient is
    /// drawn behind the (transparent) scroll content with a material overlay so
    /// text keeps system-guaranteed contrast. When the user enables
    /// **Increase Contrast**, or picks the ``GradientTheme/none`` theme, the
    /// decorative gradient is skipped and the system's opaque surfaces are used.
    ///
    /// - Parameters:
    ///   - theme: The gradient theme to display.
    ///   - frosted: When `true` (default) uses `.regularMaterial` for a more
    ///     frosted look with maximum legibility. When `false` uses
    ///     `.thinMaterial`, letting the gradient show through more vividly.
    func themedBackground(_ theme: GradientTheme, frosted: Bool = true) -> some View {
        modifier(ThemedBackgroundModifier(theme: theme, frosted: frosted))
    }
}

struct ThemedBackgroundModifier: ViewModifier {
    let theme: GradientTheme
    let frosted: Bool

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    func body(content: Content) -> some View {
        if theme == .none || colorSchemeContrast == .increased {
            // No decorative background: either "No Background" is selected, or
            // Increase Contrast is on and we defer to the system's opaque,
            // high-contrast surfaces so text legibility is guaranteed.
            content
        } else {
            // Draw the gradient, then a material scrim beneath the content. Text
            // renders on the material (system-guaranteed contrast) while the
            // gradient still tints through, keeping the theme visible without
            // putting labels directly on saturated colors.
            content
                .scrollContentBackground(.hidden)
                .background {
                    theme.gradient
                        .overlay(frosted ? Material.regularMaterial : Material.thinMaterial)
                }
        }
    }
}
```

No new dependencies. `GradientTheme` is `Equatable` (its raw type is `String`)
and `theme.gradient` is already public, so this compiles against the existing
package as-is.

### Availability

The APIs used — `Material`, `.overlay(_:)`, `.scrollContentBackground(.hidden)`,
`\.colorSchemeContrast` — are all available at or below ColorThemeKit's current
deployment target (which already requires `MeshGradient`, iOS 18+).

## Usage in an app

```swift
import ColorThemeKit
import SwiftUI

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

The two `@AppStorage` keys are the app's choice; ColorThemeKit stays free of any
persistence.

### Settings controls

Build a theme picker from the values already exposed by the package:

```swift
Picker("Background", selection: $themeID) {
    ForEach(GradientTheme.allCases) { theme in
        Text(theme.displayName).tag(theme.rawValue)
    }
}

Toggle("Frosted Background", isOn: $isFrosted)
    .disabled(GradientTheme.theme(forStoredRawValue: themeID) == GradientTheme.none)
```

## Notes on the accessibility claim

- The default (`frosted: true`, `.regularMaterial`) is the safe choice for
  claiming **Sufficient Contrast**.
- `frosted: false` (`.thinMaterial`) is a weaker contrast guarantee and is a
  user opt-in; with a saturated theme, secondary text can approach the
  threshold. Increase Contrast still overrides it (the gradient is skipped), so
  users who need contrast are always protected.
- If you want to be strict regardless of the toggle, you could force
  `.regularMaterial` — but that's already covered for the Increase Contrast case.
