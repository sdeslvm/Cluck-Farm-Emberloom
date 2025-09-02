import Foundation
import Combine

// MARK: - Data Processor for Cluck Farm

class CluckFarmDataProcessor: ObservableObject {
    @Published var processingState: ProcessingState = .idle
    @Published var dataCache: [String: Any] = [:]
    
    private var processingQueue = DispatchQueue(label: "cluckfarm.data.processing", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    enum ProcessingState {
        case idle
        case processing
        case completed
        case failed(Error)
    }
    
    func processCluckFarmGameData(_ rawData: Data) -> AnyPublisher<[String: Any], Error> {
        return Future { [weak self] promise in
            self?.processingQueue.async {
                do {
                    let processedData = try self?.parseCluckFarmData(rawData) ?? [:]
                    DispatchQueue.main.async {
                        self?.dataCache.merge(processedData) { _, new in new }
                        self?.processingState = .completed
                        promise(.success(processedData))
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.processingState = .failed(error)
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func parseCluckFarmData(_ data: Data) throws -> [String: Any] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CluckFarmDataError.invalidFormat
        }
        
        var processedData: [String: Any] = [:]
        
        // Obrabotka konfiguratsii igry
        if let gameConfig = jsonObject["gameConfig"] as? [String: Any] {
            processedData["cluckFarmConfig"] = transformGameConfig(gameConfig)
        }
        
        // Obrabotka polzovatelskih dannyh
        if let userData = jsonObject["userData"] as? [String: Any] {
            processedData["cluckFarmUserData"] = sanitizeUserData(userData)
        }
        
        // Obrabotka nastroek
        if let settings = jsonObject["settings"] as? [String: Any] {
            processedData["cluckFarmSettings"] = optimizeSettings(settings)
        }
        
        return processedData
    }
    
    private func transformGameConfig(_ config: [String: Any]) -> [String: Any] {
        var transformed: [String: Any] = [:]
        
        for (key, value) in config {
            let newKey = "cluckfarm_" + key.lowercased()
            transformed[newKey] = value
        }
        
        return transformed
    }
    
    private func sanitizeUserData(_ userData: [String: Any]) -> [String: Any] {
        var sanitized: [String: Any] = [:]
        
        let allowedKeys = ["score", "level", "achievements", "preferences"]
        
        for key in allowedKeys {
            if let value = userData[key] {
                sanitized["user_" + key] = value
            }
        }
        
        return sanitized
    }
    
    private func optimizeSettings(_ settings: [String: Any]) -> [String: Any] {
        var optimized: [String: Any] = [:]
        
        for (key, value) in settings {
            if let stringValue = value as? String {
                optimized[key] = CluckFarmSecurityLayer.shared.encryptCluckFarmData(stringValue)
            } else {
                optimized[key] = value
            }
        }
        
        return optimized
    }
    
    func clearCluckFarmCache() {
        dataCache.removeAll()
        processingState = .idle
    }
    
    func getCachedData(for key: String) -> Any? {
        return dataCache[key]
    }
}

// MARK: - Implementation handling Implementation

enum CluckFarmDataError: Error, LocalizedError {
    case invalidFormat
    case processingFailed
    case cacheMiss
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Nevernyy format dannyh CluckFarm"
        case .processingFailed:
            return "Error handling dannyh CluckFarm"
        case .cacheMiss:
            return "Data ne naydeny v keshe CluckFarm"
        }
    }
}
