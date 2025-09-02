import Foundation
import SwiftUI

// MARK: - Ядро игры Cluck Farm

class CluckFarmGameCore: ObservableObject {
    @Published var gameState: CluckFarmGameState = .initializing
    @Published var currentScore: Int = 0
    @Published var gameLevel: Int = 1
    @Published var isGameActive: Bool = false
    
    private let stateManager = CluckFarmStateManager()
    private let dataProcessor = CluckFarmDataProcessor()
    private let securityLayer = CluckFarmSecurityLayer.shared
    
    enum CluckFarmGameState: Equatable {
        case initializing
        case loading
        case ready
        case playing
        case paused
        case gameOver
        case error(String)
        
        static func == (lhs: CluckFarmGameState, rhs: CluckFarmGameState) -> Bool {
            switch (lhs, rhs) {
            case (.initializing, .initializing),
                 (.loading, .loading),
                 (.ready, .ready),
                 (.playing, .playing),
                 (.paused, .paused),
                 (.gameOver, .gameOver):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    func initializeCluckFarmGame() {
        gameState = .loading
        
        // Генерируем токен сессии
        let sessionToken = securityLayer.generateCluckFarmSessionToken()
        UserDefaults.standard.set(sessionToken, forKey: "cluckFarmSessionToken")
        
        // Инициализируем игровые данные
        setupCluckFarmGameData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gameState = .ready
        }
    }
    
    private func setupCluckFarmGameData() {
        // Настройка начальных параметров игры
        currentScore = 0
        gameLevel = 1
        isGameActive = false
        
        // Загрузка сохраненных данных
        loadCluckFarmSaveData()
    }
    
    private func loadCluckFarmSaveData() {
        if let savedScore = UserDefaults.standard.object(forKey: "cluckFarmSavedScore") as? Int {
            currentScore = savedScore
        }
        
        if let savedLevel = UserDefaults.standard.object(forKey: "cluckFarmSavedLevel") as? Int {
            gameLevel = savedLevel
        }
    }
    
    func startCluckFarmGame() {
        guard gameState == .ready else { return }
        
        gameState = .playing
        isGameActive = true
        
        // Запускаем игровой цикл
        beginCluckFarmGameLoop()
    }
    
    func pauseCluckFarmGame() {
        guard gameState == .playing else { return }
        
        gameState = .paused
        isGameActive = false
        
        // Сохраняем текущий прогресс
        saveCluckFarmProgress()
    }
    
    func resumeCluckFarmGame() {
        guard gameState == .paused else { return }
        
        gameState = .playing
        isGameActive = true
        
        // Возобновляем игровой цикл
        beginCluckFarmGameLoop()
    }
    
    func endCluckFarmGame() {
        gameState = .gameOver
        isGameActive = false
        
        // Сохраняем финальный результат
        saveCluckFarmFinalScore()
    }
    
    private func beginCluckFarmGameLoop() {
        // Основной игровой цикл
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard self.isGameActive else {
                timer.invalidate()
                return
            }
            
            self.updateCluckFarmGameState()
        }
    }
    
    private func updateCluckFarmGameState() {
        // Обновление состояния игры
        // Здесь будет логика обновления игры
    }
    
    private func saveCluckFarmProgress() {
        UserDefaults.standard.set(currentScore, forKey: "cluckFarmSavedScore")
        UserDefaults.standard.set(gameLevel, forKey: "cluckFarmSavedLevel")
    }
    
    private func saveCluckFarmFinalScore() {
        let encryptedScore = securityLayer.encryptCluckFarmData("\(currentScore)")
        UserDefaults.standard.set(currentScore, forKey: "cluckFarmFinalScore")
        
        // Очищаем временные данные
        UserDefaults.standard.removeObject(forKey: "cluckFarmSavedScore")
        UserDefaults.standard.removeObject(forKey: "cluckFarmSavedLevel")
    }
    
    func resetCluckFarmGame() {
        gameState = .initializing
        currentScore = 0
        gameLevel = 1
        isGameActive = false
        
        // Очищаем все сохраненные данные
        UserDefaults.standard.removeObject(forKey: "cluckFarmSavedScore")
        UserDefaults.standard.removeObject(forKey: "cluckFarmSavedLevel")
        UserDefaults.standard.removeObject(forKey: "cluckFarmFinalScore")
        UserDefaults.standard.removeObject(forKey: "cluckFarmSessionToken")
    }
}

// MARK: - Расширения для игровой логики

extension CluckFarmGameCore {
    var canStartGame: Bool {
        return gameState == .ready
    }
    
    var canPauseGame: Bool {
        return gameState == .playing
    }
    
    var canResumeGame: Bool {
        return gameState == .paused
    }
    
    var isGameInProgress: Bool {
        return gameState == .playing || gameState == .paused
    }
}
