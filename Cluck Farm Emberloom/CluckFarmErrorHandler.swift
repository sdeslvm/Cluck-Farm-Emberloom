import Foundation
import UIKit

// MARK: - Handler errors Implementation Cluck Farm

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
                return "Network nedostupna. Proverte podklyuchenie k internetu."
            case .invalidGameData:
                return "Nevernye data igry. Poprobuyte perezapustit app."
            case .securityValidationFailed:
                return "Error proverki safelysti. Obratites v sluzhbu podderzhki."
            case .webViewLoadFailed(let details):
                return "Ne udalos zagruzit igru: \(details)"
            case .audioInitializationFailed:
                return "Ne udalos initsializirovat audio sistemu."
            case .permissionDenied(let permission):
                return "Dostup k \(permission) zapreschen. Proverte settings prilozheniya."
            case .unexpectedError(let message):
                return "Neozhidannaya error: \(message)"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .networkUnavailable:
                return "Proverte Wi-Fi ili mobilnuyu svyaz i poprobuyte snova."
            case .invalidGameData:
                return "Perezapustite app ili pereustanovite ego."
            case .securityValidationFailed:
                return "Ubedites, chto app obnovleno do posledney versii."
            case .webViewLoadFailed:
                return "Proverte podklyuchenie k internetu i poprobuyte snova."
            case .audioInitializationFailed:
                return "Perezapustite app ili proverte settings zvuka."
            case .permissionDenied:
                return "Pereydite v Settings > Konfidentsialnost i predostavte neobhodimye permissions."
            case .unexpectedError:
                return "Perezapustite app. Esli problema povtoritsya, obratites v podderzhku."
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
