import Foundation
import SwiftUI
import UIKit

// MARK: - Цветовые утилиты для Cluck Farm

struct CluckFarmColorPalette {
    static let primaryGreen = "#228B22"
    static let secondaryGreen = "#32CD32"
    static let darkGreen = "#006400"
    static let lightGreen = "#90EE90"
    static let mintGreen = "#98FB98"
    static let accentGreen = "#00FF7F"
}

extension UIColor {
    /// Создание цвета из HEX для Cluck Farm темы
    static func cluckFarmColor(hex: String) -> UIColor {
        let sanitizedHex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0
        
        return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
    
    /// Градиент для фермерской темы
    static func cluckFarmGradientColors() -> [CGColor] {
        return [
            UIColor.cluckFarmColor(hex: CluckFarmColorPalette.primaryGreen).cgColor,
            UIColor.cluckFarmColor(hex: CluckFarmColorPalette.secondaryGreen).cgColor,
            UIColor.cluckFarmColor(hex: CluckFarmColorPalette.mintGreen).cgColor
        ]
    }
}

extension Color {
    /// SwiftUI версия цветов Cluck Farm
    static func cluckFarmTheme(hex: String) -> Color {
        let sanitizedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        return Color(
            .sRGB,
            red: Double((colorValue >> 16) & 0xFF) / 255.0,
            green: Double((colorValue >> 8) & 0xFF) / 255.0,
            blue: Double(colorValue & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

// MARK: - Анимационные утилиты

struct CluckFarmAnimationConfig {
    static let defaultDuration: Double = 0.8
    static let pulseDuration: Double = 1.2
    static let shimmerDuration: Double = 2.0
    
    static func createFeatherAnimation() -> Animation {
        return Animation.easeInOut(duration: pulseDuration).repeatForever(autoreverses: true)
    }
    
    static func createCluckAnimation() -> Animation {
        return Animation.linear(duration: shimmerDuration).repeatForever(autoreverses: false)
    }
}
