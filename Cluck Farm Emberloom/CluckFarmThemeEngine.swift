import Foundation
import SwiftUI
import UIKit

// MARK: - Engine Implementation Implementation Cluck Farm

class CluckFarmThemeEngine: ObservableObject {
    static let shared = CluckFarmThemeEngine()
    
    @Published var currentTheme: CluckFarmTheme = .rusticFarm
    @Published var isDarkMode: Bool = false
    
    enum CluckFarmTheme: String, CaseIterable {
        case rusticFarm = "rustic_farm"
        case modernBarn = "modern_barn"
        case vintageCountry = "vintage_country"
        case springMeadow = "spring_meadow"
        
        var displayName: String {
            switch self {
            case .rusticFarm: return "Derevenskaya ferma"
            case .modernBarn: return "Sovremennyy saray"
            case .vintageCountry: return "Vintazhnaya derevnya"
            case .springMeadow: return "Vesenniy lug"
            }
        }
        
        var primaryColor: String {
            switch self {
            case .rusticFarm: return "#228B22"
            case .modernBarn: return "#32CD32"
            case .vintageCountry: return "#9ACD32"
            case .springMeadow: return "#00FF7F"
            }
        }
        
        var secondaryColor: String {
            switch self {
            case .rusticFarm: return "#90EE90"
            case .modernBarn: return "#98FB98"
            case .vintageCountry: return "#ADFF2F"
            case .springMeadow: return "#00FA9A"
            }
        }
        
        var accentColor: String {
            switch self {
            case .rusticFarm: return "#F0FFF0"
            case .modernBarn: return "#FFFFFF"
            case .vintageCountry: return "#F5FFFA"
            case .springMeadow: return "#F0FFFF"
            }
        }
    }
    
    private init() {
        loadThemeSettings()
    }
    
    private func loadThemeSettings() {
        if let themeString = UserDefaults.standard.string(forKey: "CluckFarmCurrentTheme"),
           let theme = CluckFarmTheme(rawValue: themeString) {
            currentTheme = theme
        }
        isDarkMode = UserDefaults.standard.bool(forKey: "CluckFarmDarkMode")
    }
    
    func saveThemeSettings() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "CluckFarmCurrentTheme")
        UserDefaults.standard.set(isDarkMode, forKey: "CluckFarmDarkMode")
    }
    
    func setTheme(_ theme: CluckFarmTheme) {
        currentTheme = theme
        saveThemeSettings()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        saveThemeSettings()
    }
    
    func getPrimaryColor() -> Color {
        return Color.cluckFarmTheme(hex: currentTheme.primaryColor)
    }
    
    func getSecondaryColor() -> Color {
        return Color.cluckFarmTheme(hex: currentTheme.secondaryColor)
    }
    
    func getAccentColor() -> Color {
        return Color.cluckFarmTheme(hex: currentTheme.accentColor)
    }
    
    func getBackgroundGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                getPrimaryColor().opacity(0.8),
                getSecondaryColor().opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
