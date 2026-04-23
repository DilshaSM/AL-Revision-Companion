import SwiftUI

enum ProgressPalette {
    static let canvas = Color(uiColor: .init(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 254.0 / 255.0, alpha: 1))
    static let brand = Color(uiColor: .init(red: 0.0 / 255.0, green: 88.0 / 255.0, blue: 188.0 / 255.0, alpha: 1))
    static let brandSoft = Color(uiColor: .init(red: 84.0 / 255.0, green: 135.0 / 255.0, blue: 210.0 / 255.0, alpha: 1))
    static let mutedBlue = Color(uiColor: .init(red: 64.0 / 255.0, green: 94.0 / 255.0, blue: 150.0 / 255.0, alpha: 1))
    static let textPrimary = Color(uiColor: .init(red: 26.0 / 255.0, green: 28.0 / 255.0, blue: 31.0 / 255.0, alpha: 1))
    static let textSecondary = Color(uiColor: .init(red: 65.0 / 255.0, green: 71.0 / 255.0, blue: 85.0 / 255.0, alpha: 1))
    static let textTertiary = Color(uiColor: .init(red: 145.0 / 255.0, green: 151.0 / 255.0, blue: 163.0 / 255.0, alpha: 1))
    static let sectionLabel = brand.opacity(0.75)
    static let card = Color.white
    static let cardBorder = Color(uiColor: .init(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 237.0 / 255.0, alpha: 1))
    static let mutedSurface = Color(uiColor: .init(red: 237.0 / 255.0, green: 237.0 / 255.0, blue: 242.0 / 255.0, alpha: 1))
    static let rowSurface = Color(uiColor: .init(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.5))
    static let track = Color(uiColor: .init(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 231.0 / 255.0, alpha: 0.4))
    static let barFill = Color(uiColor: .init(red: 237.0 / 255.0, green: 237.0 / 255.0, blue: 242.0 / 255.0, alpha: 1))
    static let nestedSurface = Color.white
    static let iconTile = brand.opacity(0.10)
    static let iconTileMuted = mutedBlue.opacity(0.10)
    static let criticalPillBackground = Color(uiColor: .init(red: 186.0 / 255.0, green: 26.0 / 255.0, blue: 26.0 / 255.0, alpha: 0.10))
    static let criticalPillForeground = Color(uiColor: .init(red: 186.0 / 255.0, green: 26.0 / 255.0, blue: 26.0 / 255.0, alpha: 1))
    static let primaryButton = Color(uiColor: .init(red: 0.0 / 255.0, green: 87.0 / 255.0, blue: 181.0 / 255.0, alpha: 1))
    static let progressTrack = Color(uiColor: .init(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 231.0 / 255.0, alpha: 1))
    static let recommendationsCard = Color(uiColor: .init(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 237.0 / 255.0, alpha: 0.4))
    static let secondaryRecommendationsCard = Color(uiColor: .init(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.6))
    static let shadow = Color.black.opacity(0.04)
}
