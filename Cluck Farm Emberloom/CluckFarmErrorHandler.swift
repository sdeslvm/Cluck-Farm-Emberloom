import Foundation
import UIKit

// MARK: - Обработчик ошибок для Cluck Farm

class CluckFarmErrorHandler: ObservableObject {
    static let shared = CluckFarmErrorHandler()
    
    @Published var currentError: CluckFarmError?
    @Published var errorHistory: [CluckFarmErrorLog] = []
    
    private let analytics = CluckFarmAnalytics.shared
    private let haptics = CluckFarmHapticManager.shared
    
    enum CluckFarmError: LocalizedError, Equatable {
        case networkUnavailable
        case invalidGameData
        case securityValidationFailed
        case webViewLoadFailed(String)
        case audioInitializationFailed
        case permissionDenied(String)
        case unexpectedError(String)
        
        var errorDescription: String? {
            switch self {
            case .networkUnavailable:
                return "Сеть недоступна. Проверьте подключение к интернету."
            case .invalidGameData:
                return "Неверные данные игры. Попробуйте перезапустить приложение."
            case .securityValidationFailed:
                return "Ошибка проверки безопасности. Обратитесь в службу поддержки."
            case .webViewLoadFailed(let details):
                return "Не удалось загрузить игру: \(details)"
            case .audioInitializationFailed:
                return "Не удалось инициализировать аудио систему."
            case .permissionDenied(let permission):
                return "Доступ к \(permission) запрещен. Проверьте настройки приложения."
            case .unexpectedError(let message):
                return "Неожиданная ошибка: \(message)"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .networkUnavailable:
                return "Проверьте Wi-Fi или мобильную связь и попробуйте снова."
            case .invalidGameData:
                return "Перезапустите приложение или переустановите его."
            case .securityValidationFailed:
                return "Убедитесь, что приложение обновлено до последней версии."
            case .webViewLoadFailed:
                return "Проверьте подключение к интернету и попробуйте снова."
            case .audioInitializationFailed:
                return "Перезапустите приложение или проверьте настройки звука."
            case .permissionDenied:
                return "Перейдите в Настройки > Конфиденциальность и предоставьте необходимые разрешения."
            case .unexpectedError:
                return "Перезапустите приложение. Если проблема повторится, обратитесь в поддержку."
            }
        }
    }
    
    struct CluckFarmErrorLog: Codable, Identifiable {
        let id = UUID()
        let timestamp: Date
        let error: String
        let context: String
        let deviceInfo: String
        
        init(error: CluckFarmError, context: String = "") {
            self.timestamp = Date()
            self.error = error.localizedDescription
            self.context = context
            self.deviceInfo = "\(UIDevice.current.model) - iOS \(UIDevice.current.systemVersion)"
        }
    }
    
    private init() {}
    
    func handleError(_ error: CluckFarmError, context: String = "") {
        DispatchQueue.main.async {
            self.currentError = error
            
            let errorLog = CluckFarmErrorLog(error: error, context: context)
            self.errorHistory.append(errorLog)
            
            // Keep only last 50 errors
            if self.errorHistory.count > 50 {
                self.errorHistory.removeFirst()
            }
            
            // Record crash in analytics
            let nsError = NSError(domain: "CluckFarmErrorDomain", 
                                code: self.getErrorCode(for: error), 
                                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            self.analytics.recordCrash(error: nsError, stackTrace: context)
            
            // Provide haptic feedback
            self.haptics.gameError()
        }
    }
    
    private func getErrorCode(for error: CluckFarmError) -> Int {
        switch error {
        case .networkUnavailable: return 1001
        case .invalidGameData: return 1002
        case .securityValidationFailed: return 1003
        case .webViewLoadFailed: return 1004
        case .audioInitializationFailed: return 1005
        case .permissionDenied: return 1006
        case .unexpectedError: return 1999
        }
    }
    
    func clearCurrentError() {
        currentError = nil
    }
    
    func clearErrorHistory() {
        errorHistory.removeAll()
    }
    
    func getErrorReport() -> String {
        let recentErrors = errorHistory.suffix(10)
        var report = "Cluck Farm Error Report\n"
        report += "======================\n"
        report += "Recent Errors (\(recentErrors.count)):\n\n"
        
        for errorLog in recentErrors {
            report += "[\(errorLog.timestamp)] \(errorLog.error)\n"
            if !errorLog.context.isEmpty {
                report += "Context: \(errorLog.context)\n"
            }
            report += "Device: \(errorLog.deviceInfo)\n\n"
        }
        
        return report
    }
}
