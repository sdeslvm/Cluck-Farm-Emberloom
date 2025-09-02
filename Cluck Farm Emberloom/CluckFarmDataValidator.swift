import Foundation
import Network

// MARK: - Валидатор данных для Cluck Farm

class CluckFarmDataValidator: ObservableObject {
    static let shared = CluckFarmDataValidator()
    
    @Published var isValidationInProgress: Bool = false
    @Published var lastValidationResult: CluckFarmValidationResult?
    
    enum CluckFarmValidationResult {
        case success
        case networkError
        case invalidData
        case securityViolation
        case serverError(String)
        
        var description: String {
            switch self {
            case .success:
                return "Данные фермы успешно проверены"
            case .networkError:
                return "Ошибка сети при проверке данных"
            case .invalidData:
                return "Неверные данные фермы"
            case .securityViolation:
                return "Нарушение безопасности фермы"
            case .serverError(let message):
                return "Ошибка сервера: \(message)"
            }
        }
    }
    
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "CluckFarmNetworkMonitor")
    
    private init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.start(queue: monitorQueue)
    }
    
    func validateFarmData(_ data: [String: Any]) async -> CluckFarmValidationResult {
        isValidationInProgress = true
        defer { isValidationInProgress = false }
        
        // Проверка сетевого подключения
        guard networkMonitor.currentPath.status == .satisfied else {
            lastValidationResult = .networkError
            return .networkError
        }
        
        // Проверка структуры данных
        guard validateDataStructure(data) else {
            lastValidationResult = .invalidData
            return .invalidData
        }
        
        // Проверка безопасности
        guard validateDataSecurity(data) else {
            lastValidationResult = .securityViolation
            return .securityViolation
        }
        
        // Проверка на сервере
        do {
            let serverResult = try await validateOnServer(data)
            lastValidationResult = serverResult
            return serverResult
        } catch {
            let result = CluckFarmValidationResult.serverError(error.localizedDescription)
            lastValidationResult = result
            return result
        }
    }
    
    private func validateDataStructure(_ data: [String: Any]) -> Bool {
        let requiredKeys = ["farm_id", "chicken_count", "egg_count", "level", "score"]
        
        for key in requiredKeys {
            guard data[key] != nil else {
                return false
            }
        }
        
        // Проверка типов данных
        guard let chickenCount = data["chicken_count"] as? Int,
              let eggCount = data["egg_count"] as? Int,
              let level = data["level"] as? Int,
              let score = data["score"] as? Int else {
            return false
        }
        
        // Проверка разумных значений
        return chickenCount >= 0 && chickenCount <= 1000 &&
               eggCount >= 0 && eggCount <= 10000 &&
               level >= 1 && level <= 100 &&
               score >= 0
    }
    
    private func validateDataSecurity(_ data: [String: Any]) -> Bool {
        let securityLayer = CluckFarmSecurityLayer.shared
        
        // Проверка на подозрительные значения
        for (key, value) in data {
            if let stringValue = value as? String {
                if !securityLayer.validateCluckFarmEndpoint(stringValue) && key.contains("url") {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func validateOnServer(_ data: [String: Any]) async throws -> CluckFarmValidationResult {
        guard let url = URL(string: "https://cluckfargame.com/api/validate") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("CluckFarm/1.0", forHTTPHeaderField: "User-Agent")
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            return .success
        case 400:
            return .invalidData
        case 403:
            return .securityViolation
        default:
            return .serverError("HTTP \(httpResponse.statusCode)")
        }
    }
    
    func validateFarmURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        
        let allowedHosts = ["cluckfargame.com", "www.cluckfargame.com"]
        guard let host = url.host, allowedHosts.contains(host) else { return false }
        
        return url.scheme == "https"
    }
    
    deinit {
        networkMonitor.cancel()
    }
}
