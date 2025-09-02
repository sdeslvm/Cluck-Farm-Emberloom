import Foundation
import UIKit

// MARK: - Менеджер тактильной обратной связи для Cluck Farm

class CluckFarmHapticManager: ObservableObject {
    static let shared = CluckFarmHapticManager()
    
    @Published var isHapticsEnabled: Bool = true
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadHapticSettings()
        prepareHaptics()
    }
    
    private func loadHapticSettings() {
        isHapticsEnabled = userDefaults.bool(forKey: "CluckFarmHapticsEnabled")
        if userDefaults.object(forKey: "CluckFarmHapticsEnabled") == nil {
            isHapticsEnabled = true // Default to enabled
        }
    }
    
    private func prepareHaptics() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    func saveHapticSettings() {
        userDefaults.set(isHapticsEnabled, forKey: "CluckFarmHapticsEnabled")
    }
    
    func toggleHaptics() {
        isHapticsEnabled.toggle()
        saveHapticSettings()
    }
    
    // MARK: - Haptic Feedback Methods
    
    func cluckTap() {
        guard isHapticsEnabled else { return }
        lightImpact.impactOccurred()
    }
    
    func farmAction() {
        guard isHapticsEnabled else { return }
        mediumImpact.impactOccurred()
    }
    
    func emberloomEffect() {
        guard isHapticsEnabled else { return }
        heavyImpact.impactOccurred()
    }
    
    func menuSelection() {
        guard isHapticsEnabled else { return }
        selectionFeedback.selectionChanged()
    }
    
    func gameSuccess() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
    }
    
    func gameWarning() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func gameError() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.error)
    }
    
    func customPattern() {
        guard isHapticsEnabled else { return }
        
        DispatchQueue.main.async {
            self.lightImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.mediumImpact.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.lightImpact.impactOccurred()
                }
            }
        }
    }
}
