import Testing
import SwiftUI
import ColorThemeKit

struct ThemeContrastTests {
    @Test func contrastRatioMatchesWCAGExtremes() {
        #expect(abs(ThemeContrast.contrastRatio(.white, .black) - 21) < 0.0001)
        #expect(abs(ThemeContrast.contrastRatio(.white, .white) - 1) < 0.0001)
    }

    @Test func plainIsNeverFlagged() {
        #expect(!GradientTheme.none.isLowContrast(in: .light))
        #expect(!GradientTheme.none.isLowContrast(in: .dark))
    }

    @Test(arguments: [GradientTheme.natural, .graphite, .skyNestLite, .sunrise])
    func adaptiveSubtleThemesPassInBothAppearances(theme: GradientTheme) {
        #expect(!theme.isLowContrast(in: .light))
        #expect(!theme.isLowContrast(in: .dark))
    }

    /// Fixed-palette themes fail in the appearance they don't suit.
    @Test func fixedPalettesAreFlaggedInTheMismatchedAppearance() {
        #expect(GradientTheme.darkSlateBerry.isLowContrast(in: .light))
        #expect(!GradientTheme.darkSlateBerry.isLowContrast(in: .dark))
        #expect(GradientTheme.lightRoseGold.isLowContrast(in: .dark))
        #expect(!GradientTheme.lightRoseGold.isLowContrast(in: .light))
    }

    @Test func saturatedThemesAreFlaggedInLightMode() {
        #expect(GradientTheme.skyNest.isLowContrast(in: .light))
        #expect(GradientTheme.glacier.isLowContrast(in: .light))
    }

    @Test func glacierMeshIsFlaggedInBothAppearances() {
        #expect(GradientTheme.glacier.isLowContrast(in: .light))
        #expect(GradientTheme.glacier.isLowContrast(in: .dark))
    }

    @Test(arguments: GradientTheme.allCases)
    func thinMaterialDoesNotRemoveWarnings(theme: GradientTheme) {
        for scheme in [ColorScheme.light, .dark] {
            let regular = theme.estimatedContrast(in: scheme)
            let thin = theme.estimatedContrast(in: scheme, frosted: false)
            #expect((1...21).contains(regular.primary))
            #expect((1...21).contains(regular.secondary))
            #expect((1...21).contains(thin.primary))
            #expect((1...21).contains(thin.secondary))
            if theme.isLowContrast(in: scheme) {
                #expect(theme.isLowContrast(in: scheme, frosted: false))
            }
            if theme == .none {
                #expect(!theme.isLowContrast(in: scheme, frosted: false))
            }
        }
    }

    @Test func luminanceAndBlending() {
        #expect(ThemeContrast.relativeLuminance(.black) == 0)
        #expect(ThemeContrast.relativeLuminance(.white) == 1)
        #expect(abs(ThemeContrast.relativeLuminance(.init(red: 1, green: 0, blue: 0)) - 0.2126) < 0.0001)
        #expect(ThemeContrast.blend(.white, opacity: 0, over: .black) == .black)
        #expect(ThemeContrast.blend(.white, opacity: 1, over: .black) == .white)
        #expect(ThemeContrast.blend(.white, opacity: 0.5, over: .black) == .init(red: 0.5, green: 0.5, blue: 0.5))
    }
}
