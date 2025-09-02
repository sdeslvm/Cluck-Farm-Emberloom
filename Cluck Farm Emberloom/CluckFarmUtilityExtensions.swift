import Foundation
import SwiftUI
import WebKit

// MARK: - Расширения утилит для Cluck Farm

extension String {
    var cluckFarmHash: String {
        return CluckFarmSecurityLayer.shared.obfuscateCluckFarmString(self)
    }
    
    var cluckFarmDeobfuscated: String {
        return CluckFarmSecurityLayer.shared.deobfuscateCluckFarmString(self)
    }
    
    func cluckFarmValidateURL() -> Bool {
        return CluckFarmSecurityLayer.shared.validateCluckFarmEndpoint(self)
    }
}

extension View {
    func cluckFarmTransition(isActive: Bool) -> some View {
        self.modifier(CluckFarmTransitionEffect(isActive: isActive))
    }
    
    func cluckFarmFeatherAnimation() -> some View {
        self.animation(CluckFarmAnimationEngine.shared.createFeatherEffect(), value: UUID())
    }
}

extension UserDefaults {
    func setCluckFarmSecure(_ value: String, forKey key: String) {
        let encrypted = CluckFarmSecurityLayer.shared.encryptCluckFarmData(value)
        self.set(encrypted, forKey: "cluckfarm_\(key)")
    }
    
    func cluckFarmSecureString(forKey key: String) -> String? {
        guard let encrypted = self.string(forKey: "cluckfarm_\(key)") else { return nil }
        return CluckFarmSecurityLayer.shared.decryptCluckFarmData(encrypted)
    }
}

extension URL {
    var isCluckFarmSecure: Bool {
        return self.absoluteString.cluckFarmValidateURL()
    }
    
    static func cluckFarmEndpoint(from string: String) -> URL? {
        guard string.cluckFarmValidateURL() else { return nil }
        return URL(string: string)
    }
}

extension Data {
    func cluckFarmProcess() -> [String: Any]? {
        let processor = CluckFarmDataProcessor()
        var result: [String: Any]?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        _ = processor.processCluckFarmGameData(self)
            .sink(
                receiveCompletion: { _ in semaphore.signal() },
                receiveValue: { data in 
                    result = data
                    semaphore.signal()
                }
            )
        
        semaphore.wait()
        return result
    }
}

// MARK: - Дополнительные протоколы для обфускации

protocol CluckFarmConfigurable {
    func configureCluckFarmSettings()
    func validateCluckFarmState() -> Bool
}

protocol CluckFarmAnimatable {
    func startCluckFarmAnimation()
    func stopCluckFarmAnimation()
}

protocol CluckFarmSecurable {
    func applyCluckFarmSecurity()
    func removeCluckFarmSecurity()
}

// MARK: - Вспомогательные структуры

struct CluckFarmConstants {
    static let gameVersion = "2.0.0"
    static let buildNumber = "1001"
    static let apiVersion = "v2"
    static let maxRetries = 3
    static let timeoutInterval: TimeInterval = 30.0
    
    struct Endpoints {
        static let base = "https://cluckfargame.com"
        static let app = "\(base)/app"
        static let api = "\(base)/api/\(apiVersion)"
        static let config = "\(api)/config"
        static let scores = "\(api)/scores"
    }
    
    struct Keys {
        static let sessionToken = "cluckFarmSessionToken"
        static let userPrefs = "cluckFarmUserPreferences"
        static let gameData = "cluckFarmGameData"
        static let highScore = "cluckFarmHighScore"
    }
}

struct CluckFarmMetrics {
    static func trackEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        // Аналитика событий
        let timestamp = Date().timeIntervalSince1970
        let eventData = [
            "event": eventName,
            "timestamp": timestamp,
            "parameters": parameters
        ] as [String : Any]
        
        // Сохраняем в локальное хранилище для последующей отправки
        var events = UserDefaults.standard.array(forKey: "cluckFarmEvents") as? [[String: Any]] ?? []
        events.append(eventData)
        UserDefaults.standard.set(events, forKey: "cluckFarmEvents")
    }
    
    static func flushEvents() {
        UserDefaults.standard.removeObject(forKey: "cluckFarmEvents")
    }
}
