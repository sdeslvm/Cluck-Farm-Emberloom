import Foundation
import SwiftUI

// MARK: - Менеджер настроек для Cluck Farm

class CluckFarmSettingsManager: ObservableObject {
    static let shared = CluckFarmSettingsManager()
    
    @Published var gameSettings: CluckFarmGameSettings
    @Published var privacySettings: CluckFarmPrivacySettings
    @Published var performanceSettings: CluckFarmPerformanceSettings
    
    private let userDefaults = UserDefaults.standard
    private let securityLayer = CluckFarmSecurityLayer.shared
    
    struct CluckFarmGameSettings: Codable {
        var soundEnabled: Bool = true
        var hapticsEnabled: Bool = true
        var autoSaveEnabled: Bool = true
        var difficulty: CluckFarmDifficulty = .medium
        var language: String = "ru"
        var notifications: Bool = true
        
        enum CluckFarmDifficulty: String, CaseIterable, Codable {
            case easy = "easy"
            case medium = "medium" 
            case hard = "hard"
            
            var displayName: String {
                switch self {
                case .easy: return "Легкий"
                case .medium: return "Средний"
                case .hard: return "Сложный"
                }
            }
        }
    }
    
    struct CluckFarmPrivacySettings: Codable {
        var analyticsEnabled: Bool = false
        var crashReportingEnabled: Bool = true
        var locationTrackingEnabled: Bool = false
        var advertisingTrackingEnabled: Bool = false
        var dataCollection: CluckFarmDataCollection = .minimal
        
        enum CluckFarmDataCollection: String, CaseIterable, Codable {
            case none = "none"
            case minimal = "minimal"
            case standard = "standard"
            
            var displayName: String {
                switch self {
                case .none: return "Отключено"
                case .minimal: return "Минимальное"
                case .standard: return "Стандартное"
                }
            }
        }
    }
    
    struct CluckFarmPerformanceSettings: Codable {
        var highQualityGraphics: Bool = true
        var particleEffects: Bool = true
        var backgroundProcessing: Bool = false
        var memoryOptimization: Bool = true
        var frameRateLimit: Int = 60
    }
    
    private init() {
        self.gameSettings = CluckFarmGameSettings()
        self.privacySettings = CluckFarmPrivacySettings()
        self.performanceSettings = CluckFarmPerformanceSettings()
        
        loadSettings()
    }
    
    private func loadSettings() {
        if let gameData = userDefaults.data(forKey: "CluckFarmGameSettings"),
           let settings = try? JSONDecoder().decode(CluckFarmGameSettings.self, from: gameData) {
            gameSettings = settings
        }
        
        if let privacyData = userDefaults.data(forKey: "CluckFarmPrivacySettings"),
           let settings = try? JSONDecoder().decode(CluckFarmPrivacySettings.self, from: privacyData) {
            privacySettings = settings
        }
        
        if let performanceData = userDefaults.data(forKey: "CluckFarmPerformanceSettings"),
           let settings = try? JSONDecoder().decode(CluckFarmPerformanceSettings.self, from: performanceData) {
            performanceSettings = settings
        }
    }
    
    func saveSettings() {
        if let gameData = try? JSONEncoder().encode(gameSettings) {
            userDefaults.set(gameData, forKey: "CluckFarmGameSettings")
        }
        
        if let privacyData = try? JSONEncoder().encode(privacySettings) {
            userDefaults.set(privacyData, forKey: "CluckFarmPrivacySettings")
        }
        
        if let performanceData = try? JSONEncoder().encode(performanceSettings) {
            userDefaults.set(performanceData, forKey: "CluckFarmPerformanceSettings")
        }
    }
    
    func resetToDefaults() {
        gameSettings = CluckFarmGameSettings()
        privacySettings = CluckFarmPrivacySettings()
        performanceSettings = CluckFarmPerformanceSettings()
        saveSettings()
    }
    
    func exportSettings() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        var export = "Cluck Farm Settings Export\n"
        export += "==========================\n\n"
        
        if let gameData = try? encoder.encode(gameSettings),
           let gameString = String(data: gameData, encoding: .utf8) {
            export += "Game Settings:\n\(gameString)\n\n"
        }
        
        if let privacyData = try? encoder.encode(privacySettings),
           let privacyString = String(data: privacyData, encoding: .utf8) {
            export += "Privacy Settings:\n\(privacyString)\n\n"
        }
        
        if let performanceData = try? encoder.encode(performanceSettings),
           let performanceString = String(data: performanceData, encoding: .utf8) {
            export += "Performance Settings:\n\(performanceString)\n"
        }
        
        return export
    }
}
