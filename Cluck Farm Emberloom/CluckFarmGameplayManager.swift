import Foundation
import SwiftUI
import GameKit

// MARK: - Manager Implementation Implementation Implementation Cluck Farm

@MainActor
class CluckFarmGameplayManager: NSObject, ObservableObject {
    static let shared = CluckFarmGameplayManager()
    
    @Published var currentLevel: Int = 1
    @Published var totalScore: Int = 0
    @Published var chickenCount: Int = 0
    @Published var eggCount: Int = 0
    @Published var farmExperience: Int = 0
    @Published var dailyBonus: Int = 0
    @Published var achievements: [CluckFarmAchievement] = []
    
    private let gameCore = CluckFarmGameCore()
    private let analytics = CluckFarmAnalytics.shared
    private let notifications = CluckFarmNotificationManager.shared
    private let haptics = CluckFarmHapticManager.shared
    
    struct CluckFarmAchievement: Codable, Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let iconName: String
        let pointsRequired: Int
        let isUnlocked: Bool
        let unlockedDate: Date?
        
        static let allAchievements = [
            CluckFarmAchievement(title: "Pervyy tsyplenok", description: "Poluchite pervogo tsyplenka", iconName: "🐣", pointsRequired: 10, isUnlocked: false, unlockedDate: nil),
            CluckFarmAchievement(title: "Master fermer", description: "Dostignite 100 ochkov", iconName: "🏆", pointsRequired: 100, isUnlocked: false, unlockedDate: nil),
            CluckFarmAchievement(title: "Korol kuryatnika", description: "Soberite 50 yaits", iconName: "👑", pointsRequired: 500, isUnlocked: false, unlockedDate: nil),
            CluckFarmAchievement(title: "Legenda fermy", description: "Dostignite 10 urovnya", iconName: "⭐", pointsRequired: 1000, isUnlocked: false, unlockedDate: nil)
        ]
    }
    
    override init() {
        super.init()
        loadGameData()
        setupGameCenter()
    }
    
    private func loadGameData() {
        currentLevel = UserDefaults.standard.integer(forKey: "CluckFarmCurrentLevel")
        if currentLevel == 0 { currentLevel = 1 }
        
        totalScore = UserDefaults.standard.integer(forKey: "CluckFarmTotalScore")
        chickenCount = UserDefaults.standard.integer(forKey: "CluckFarmChickenCount")
        eggCount = UserDefaults.standard.integer(forKey: "CluckFarmEggCount")
        farmExperience = UserDefaults.standard.integer(forKey: "CluckFarmExperience")
        
        if let achievementData = UserDefaults.standard.data(forKey: "CluckFarmAchievements"),
           let savedAchievements = try? JSONDecoder().decode([CluckFarmAchievement].self, from: achievementData) {
            achievements = savedAchievements
        } else {
            achievements = CluckFarmAchievement.allAchievements
        }
    }
    
    private func saveGameData() {
        UserDefaults.standard.set(currentLevel, forKey: "CluckFarmCurrentLevel")
        UserDefaults.standard.set(totalScore, forKey: "CluckFarmTotalScore")
        UserDefaults.standard.set(chickenCount, forKey: "CluckFarmChickenCount")
        UserDefaults.standard.set(eggCount, forKey: "CluckFarmEggCount")
        UserDefaults.standard.set(farmExperience, forKey: "CluckFarmExperience")
        
        if let achievementData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(achievementData, forKey: "CluckFarmAchievements")
        }
    }
    
    private func setupGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let error = error {
                print("Game Center authentication failed: \(error)")
            }
        }
    }
    
    func addScore(_ points: Int) {
        totalScore += points
        farmExperience += points / 10
        
        checkForLevelUp()
        checkForAchievements()
        saveGameData()
        
        haptics.farmAction()
    }
    
    func addChicken() {
        chickenCount += 1
        addScore(10)
        haptics.cluckTap()
    }
    
    func collectEgg() {
        eggCount += 1
        addScore(5)
        haptics.cluckTap()
    }
    
    private func checkForLevelUp() {
        let requiredExperience = currentLevel * 100
        if farmExperience >= requiredExperience {
            currentLevel += 1
            farmExperience -= requiredExperience
            
            notifications.scheduleAchievementNotification(
                title: "Novyy uroven!",
                message: "Pozdravlyaem! Vy dostigli \(currentLevel) urovnya fermy!"
            )
            
            haptics.gameSuccess()
        }
    }
    
    private func checkForAchievements() {
        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked && totalScore >= achievements[i].pointsRequired {
                achievements[i] = CluckFarmAchievement(
                    title: achievements[i].title,
                    description: achievements[i].description,
                    iconName: achievements[i].iconName,
                    pointsRequired: achievements[i].pointsRequired,
                    isUnlocked: true,
                    unlockedDate: Date()
                )
                
                notifications.scheduleAchievementNotification(
                    title: "Dostizhenie razblokirovano!",
                    message: achievements[i].title
                )
                
                haptics.gameSuccess()
            }
        }
    }
    
    func resetGameProgress() {
        currentLevel = 1
        totalScore = 0
        chickenCount = 0
        eggCount = 0
        farmExperience = 0
        achievements = CluckFarmAchievement.allAchievements
        saveGameData()
    }
    
    func getDailyBonus() -> Int {
        let lastBonusDate = UserDefaults.standard.object(forKey: "CluckFarmLastBonusDate") as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastBonusDate {
            let lastBonusDay = Calendar.current.startOfDay(for: lastDate)
            if today > lastBonusDay {
                let bonus = currentLevel * 10
                dailyBonus = bonus
                UserDefaults.standard.set(Date(), forKey: "CluckFarmLastBonusDate")
                addScore(bonus)
                return bonus
            }
        } else {
            let bonus = currentLevel * 10
            dailyBonus = bonus
            UserDefaults.standard.set(Date(), forKey: "CluckFarmLastBonusDate")
            addScore(bonus)
            return bonus
        }
        
        return 0
    }
}
