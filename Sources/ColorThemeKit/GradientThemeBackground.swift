import SwiftUI

/// Draws a ``GradientTheme``'s gradient, adapting to the environment's color scheme.
///
/// This is the concrete view returned by ``GradientTheme/gradient``. It reads
/// `\.colorScheme` from the environment so the theme updates live when the user
/// switches between light and dark mode.
struct GradientThemeBackground: View {
    let theme: GradientTheme

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            switch theme {
            case .glacier:
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ],
                    colors: theme.meshColors(for: colorScheme)
                )
            default:
                LinearGradient(
                    colors: theme.colors(for: colorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }
}
