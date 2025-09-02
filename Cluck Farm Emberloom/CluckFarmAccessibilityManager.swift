import Foundation
import SwiftUI
import UIKit

// MARK: - Менеджер доступности для Cluck Farm

class CluckFarmAccessibilityManager: ObservableObject {
    static let shared = CluckFarmAccessibilityManager()
    
    @Published var isVoiceOverEnabled: Bool = false
    @Published var isReduceMotionEnabled: Bool = false
    @Published var isHighContrastEnabled: Bool = false
    @Published var fontSizeMultiplier: CGFloat = 1.0
    
    private init() {
        checkAccessibilitySettings()
        setupAccessibilityNotifications()
    }
    
    private func checkAccessibilitySettings() {
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
        
        if UIAccessibility.prefersCrossFadeTransitions {
            fontSizeMultiplier = 1.2
        }
    }
    
    private func setupAccessibilityNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        }
    }
    
    func getAccessibilityLabel(for element: String) -> String {
        switch element {
        case "chicken_button":
            return "Кнопка курицы. Нажмите, чтобы взаимодействовать с курицей."
        case "egg_collection":
            return "Сбор яиц. Нажмите, чтобы собрать яйца."
        case "farm_settings":
            return "Настройки фермы. Нажмите, чтобы открыть настройки."
        case "game_score":
            return "Счет игры. Текущий счет отображается здесь."
        default:
            return element
        }
    }
    
    func getAccessibilityHint(for element: String) -> String {
        switch element {
        case "chicken_button":
            return "Двойное нажатие для кормления курицы"
        case "egg_collection":
            return "Двойное нажатие для сбора всех яиц"
        case "farm_settings":
            return "Двойное нажатие для открытия меню настроек"
        default:
            return ""
        }
    }
    
    func announceToVoiceOver(_ message: String) {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    func focusOnElement(_ element: UIView) {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .layoutChanged, argument: element)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
