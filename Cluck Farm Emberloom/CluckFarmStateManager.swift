import Foundation
import SwiftUI

// MARK: - Менеджер состояний для Cluck Farm

class CluckFarmStateManager: ObservableObject {
    @Published var currentCluckFarmState: CluckFarmGameState = .initializing
    @Published var loadingProgress: Double = 0.0
    @Published var isNetworkAvailable: Bool = true
    @Published var errorMessage: String?
    
    private var stateTransitionHandlers: [CluckFarmGameState: () -> Void] = [:]
    
    enum CluckFarmGameState: CaseIterable {
        case initializing
        case loading
        case ready
        case playing
        case paused
        case error
        case offline
        
        var displayName: String {
            switch self {
            case .initializing: return "Инициализация фермы"
            case .loading: return "Загрузка курятника"
            case .ready: return "Ферма готова"
            case .playing: return "Игра на ферме"
            case .paused: return "Пауза фермы"
            case .error: return "Ошибка фермы"
            case .offline: return "Ферма оффлайн"
            }
        }
    }
    
    func transitionToState(_ newState: CluckFarmGameState) {
        guard currentCluckFarmState != newState else { return }
        
        let previousState = currentCluckFarmState
        currentCluckFarmState = newState
        
        executeStateTransition(from: previousState, to: newState)
        stateTransitionHandlers[newState]?()
    }
    
    private func executeStateTransition(from: CluckFarmGameState, to: CluckFarmGameState) {
        switch (from, to) {
        case (_, .loading):
            loadingProgress = 0.0
        case (_, .error):
            // Сохраняем состояние ошибки
            break
        case (_, .ready):
            loadingProgress = 1.0
            errorMessage = nil
        default:
            break
        }
    }
    
    func registerStateHandler(for state: CluckFarmGameState, handler: @escaping () -> Void) {
        stateTransitionHandlers[state] = handler
    }
    
    func updateLoadingProgress(_ progress: Double) {
        loadingProgress = min(1.0, max(0.0, progress))
        if progress >= 1.0 && currentCluckFarmState == .loading {
            transitionToState(.ready)
        }
    }
    
    func setError(_ message: String) {
        errorMessage = message
        transitionToState(.error)
    }
    
    func clearError() {
        errorMessage = nil
        if currentCluckFarmState == .error {
            transitionToState(.initializing)
        }
    }
}

// MARK: - Расширения для удобства

extension CluckFarmStateManager {
    var isLoading: Bool {
        return currentCluckFarmState == .loading || currentCluckFarmState == .initializing
    }
    
    var canPlay: Bool {
        return currentCluckFarmState == .ready && isNetworkAvailable
    }
    
    var shouldShowError: Bool {
        return currentCluckFarmState == .error && errorMessage != nil
    }
}
