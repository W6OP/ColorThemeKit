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
