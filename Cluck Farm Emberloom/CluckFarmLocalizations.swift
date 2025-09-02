import Foundation

// MARK: - Локализация для Cluck Farm

class CluckFarmLocalizations {
    static let shared = CluckFarmLocalizations()
    
    private let localizedStrings: [String: [String: String]] = [
        "ru": [
            "app_name": "Cluck Farm: Emberloom",
            "loading_message": "Загружается ферма...",
            "game_ready": "Ферма готова к игре!",
            "network_error": "Ошибка сети",
            "retry_button": "Повторить",
            "settings_title": "Настройки фермы",
            "audio_settings": "Звуковые настройки",
            "privacy_settings": "Настройки конфиденциальности",
            "performance_settings": "Настройки производительности",
            "about_game": "О игре",
            "version": "Версия",
            "support": "Поддержка",
            "rate_app": "Оценить приложение",
            "share_app": "Поделиться",
            "tutorial": "Обучение",
            "achievements": "Достижения",
            "leaderboard": "Таблица лидеров",
            "farm_status": "Статус фермы",
            "chicken_count": "Количество кур",
            "egg_production": "Производство яиц",
            "farm_level": "Уровень фермы",
            "daily_bonus": "Ежедневный бонус",
            "special_events": "Специальные события"
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
