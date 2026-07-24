import SwiftUI

public extension Color {
    /// Creates a color from a packed 32-bit ARGB integer in the form `0xAARRGGBB`.
    init(argb: Int) {
        let a = Double((argb >> 24) & 0xFF) / 255.0
        let r = Double((argb >> 16) & 0xFF) / 255.0
        let g = Double((argb >> 8) & 0xFF) / 255.0
        let b = Double(argb & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Returns the color packed into a 32-bit ARGB integer in the form `0xAARRGGBB`.
    ///
    /// The color is resolved in the sRGB color space using the SwiftUI-native
    /// ``Color/resolve(in:)`` API, so no UIKit/AppKit dependency is required. Each
    /// channel is clamped to the `0...255` range.
    func toArgb() -> Int {
        let resolved = resolve(in: EnvironmentValues())
        func channel(_ value: Float) -> Int {
            Int((min(max(value, 0), 1) * 255).rounded())
        }
        return (channel(resolved.opacity) << 24)
            | (channel(resolved.red) << 16)
            | (channel(resolved.green) << 8)
            | channel(resolved.blue)
    }
}
