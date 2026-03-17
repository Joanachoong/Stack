import SwiftUI
import Foundation

/// App-wide color constants converted from constants/colors.ts.
///
/// All colors match the original React Native theme values used throughout
/// the ThethaFeed application for consistent visual styling.
struct AppColors {
    

//    // OPTION 1 —
    static let primary         = Color(hex: "#0B8A1F")               // deep sport green (button bg, accents)
    static let primaryDark     = Color(hex: "#17BB2E")               // vibrant green (pressed state, highlights)
    static let primaryMuted    = Color(hex: "#3DA34D")               // mid-tone green (secondary actions)
    static let background      = Color(hex: "#E3FEE9")               // light mint (main bg)
    static let surface         = Color(hex: "#FFFFFF")               // white (unselected card bg)
    static let surfaceSelected = Color(hex: "#17BB2E").opacity(0.14) // green-tinted (selected card bg)
    static let text            = Color(hex: "#0D1B0F")               // near-black green (body text)
    static let textMuted       = Color(hex: "#3E5742")               // dark sage (subtitles, captions)
    static let border          = Color(hex: "#A8E6B3")               // soft green (card borders, dividers)
    static let borderSelected  = Color(hex: "#17BB2E").opacity(0.50) // vibrant green (selected border)
    static let progressTrack   = Color(hex: "#B9F0C5")               // pale mint (track bg)
    static let success         = Color(hex: "#17BB2E")               // vibrant green (success, active)
    static let successDark     = Color(hex: "#0B8A1F")               // deep green (success pressed)
    static let danger          = Color(hex: "#D32F2F")               // strong red (errors, destructive)

}

//

////    // OPTION 2 — // MARK: Midnight theme
//
//     static let primary         = Color(hex: "#7CB342")               // neon green (button bg, accents)
//     static let primaryDark     = Color(hex: "#5A9E6E")               // teal green (pressed state)
//     static let primaryMuted    = Color(hex: "#5C9B3A")               // darker muted green
//    //static let background      = Color(hex: "#0A1A4A")               // deep bright navy
//    static let background      = Color(hex: "#13322C")               // deep bright navy
//    static let surface         = Color(hex: "#7CB342").opacity(0.06) // unselected card bg
//    static let surfaceSelected = Color(hex: "#7CB342").opacity(0.14) // selected card bg
//    static let text            = Color(hex: "#E8EDF5")               // off-white
//    static let textMuted       = Color(hex: "#9E9EAE")               // muted gray
//    static let border          = Color(hex: "#7CB342").opacity(0.15) // unselected card border
//    static let borderSelected  = Color(hex: "#7CB342").opacity(0.50) // selected card border
//    static let progressTrack   = Color(hex: "#1A2D6A")               // light navy variant
//    static let success         = Color(hex: "#14AE5C")
//    static let successDark     = Color(hex: "#009951")
//    static let danger          = Color(hex: "#C00F0C")
//}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Creates a Color from a hex string (e.g., "#AEE92B" or "AEE92B").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
