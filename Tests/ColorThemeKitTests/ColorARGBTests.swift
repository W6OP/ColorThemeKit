import SwiftUI
import Testing
@testable import ColorThemeKit

struct ColorARGBTests {
    @Test("Packed ARGB values round-trip through Color")
    func argbRoundTrip() {
        let values = [
            0xFF00_0000, // opaque black
            0xFFFF_FFFF, // opaque white
            0xFFFF_0000, // opaque red
            0xFF00_FF00, // opaque green
            0xFF00_00FF, // opaque blue
            0x8012_3456  // partial alpha
        ]

        for argb in values {
            let restored = Color(argb: argb).toArgb()
            #expect(restored == argb)
        }
    }

    @Test("Every theme exposes non-empty palettes for both schemes")
    func themePalettesAreNonEmpty() {
        for theme in GradientTheme.allCases {
            #expect(!theme.colors(for: .light).isEmpty)
            #expect(!theme.colors(for: .dark).isEmpty)
        }
    }
}
