import Foundation

// MARK: - Localization Implementation Cluck Farm

class CluckFarmLocalizations {
    static let shared = CluckFarmLocalizations()
    
    private let localizedStrings: [String: [String: String]] = [
        "ru": [
            "app_name": "Cluck Farm: Emberloom",
            "loading_message": "Zagruzhaetsya ferma...",
            "game_ready": "Ferma gotova k igre!",
            "network_error": "Error seti",
            "retry_button": "Povtorit",
            "settings_title": "Settings fermy",
            "audio_settings": "Zvukovye settings",
            "privacy_settings": "Settings konfidentsialnosti",
            "performance_settings": "Settings proizvoditelnosti",
            "about_game": "O igre",
            "version": "Versiya",
            "support": "Podderzhka",
            "rate_app": "Otsenit app",
            "share_app": "Podelitsya",
            "tutorial": "Obuchenie",
            "achievements": "Dostizheniya",
            "leaderboard": "Tablitsa liderov",
            "farm_status": "Status fermy",
            "chicken_count": "Kolichestvo kur",
            "egg_production": "Proizvodstvo yaits",
            "farm_level": "Uroven fermy",
            "daily_bonus": "Ezhednevnyy bonus",
            "special_events": "Spetsialnye sobytiya"
        ],
        "en": [
            "app_name": "Cluck Farm: Emberloom",
            "loading_message": "Loading farm...",
            "game_ready": "Farm ready to play!",
            "network_error": "Network error",
            "retry_button": "Retry",
            "settings_title": "Farm Settings",
            "audio_settings": "Audio Settings",
            "privacy_settings": "Privacy Settings",
            "performance_settings": "Performance Settings",
            "about_game": "About Game",
            "version": "Version",
            "support": "Support",
            "rate_app": "Rate App",
            "share_app": "Share",
            "tutorial": "Tutorial",
            "achievements": "Achievements",
            "leaderboard": "Leaderboard",
            "farm_status": "Farm Status",
            "chicken_count": "Chicken Count",
            "egg_production": "Egg Production",
            "farm_level": "Farm Level",
            "daily_bonus": "Daily Bonus",
            "special_events": "Special Events"
        ]
    ]
    
    private var currentLanguage: String {
        return Locale.current.languageCode ?? "en"
    }
    
    func localizedString(for key: String) -> String {
        let language = localizedStrings[currentLanguage] != nil ? currentLanguage : "en"
        return localizedStrings[language]?[key] ?? key
    }
    
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "CluckFarmLanguage")
    }
    
    func getSupportedLanguages() -> [String] {
        return Array(localizedStrings.keys).sorted()
    }
}
