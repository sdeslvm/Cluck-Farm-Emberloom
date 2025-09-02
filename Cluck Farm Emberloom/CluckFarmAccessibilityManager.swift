import Foundation
import SwiftUI
import UIKit

// MARK: - Manager availability Implementation Cluck Farm

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
            return "Knopka kuritsy. Nazhmite, chtoby vzaimodeystvovat s kuritsey."
        case "egg_collection":
            return "Sbor yaits. Nazhmite, chtoby sobrat yaytsa."
        case "farm_settings":
            return "Settings fermy. Nazhmite, chtoby otkryt settings."
        case "game_score":
            return "Schet igry. Tekuschiy schet otobrazhaetsya zdes."
        default:
            return element
        }
    }
    
    func getAccessibilityHint(for element: String) -> String {
        switch element {
        case "chicken_button":
            return "Dvoynoe nazhatie dlya kormleniya kuritsy"
        case "egg_collection":
            return "Dvoynoe nazhatie dlya sbora vseh yaits"
        case "farm_settings":
            return "Dvoynoe nazhatie dlya otkrytiya menyu nastroek"
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
