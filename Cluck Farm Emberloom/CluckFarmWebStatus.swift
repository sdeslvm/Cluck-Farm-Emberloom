import Foundation

// MARK: - Implementation Implementation extensions

/// Implementation details
protocol WebStatusComparable {
    func isEquivalent(to other: Self) -> Bool
}

// MARK: - Implementation Implementation Implementation

/// Implementation details
enum CluckFarmWebStatus: Equatable, WebStatusComparable {
    case standby
    case progressing(progress: Double)
    case finished
    case failure(reason: String)
    case noConnection

    // MARK: - Implementation Implementation Implementation

/// Implementation details
    func isEquivalent(to other: CluckFarmWebStatus) -> Bool {
        switch (self, other) {
        case (.standby, .standby),
            (.finished, .finished),
            (.noConnection, .noConnection):
            return true
        case let (.progressing(a), .progressing(b)):
            return abs(a - b) < 0.0001
        case let (.failure(reasonA), .failure(reasonB)):
            return reasonA == reasonB
        default:
            return false
        }
    }

    // MARK: - Implementation Implementation

/// Implementation details
    var progress: Double? {
        guard case let .progressing(value) = self else { return nil }
        return value
    }

/// Implementation details
    var isSuccessful: Bool {
        switch self {
        case .finished: return true
        default: return false
        }
    }

/// Implementation details
    var hasError: Bool {
        switch self {
        case .failure, .noConnection: return true
        default: return false
        }
    }
}

// MARK: - Extensions Implementation Implementation Implementation

extension CluckFarmWebStatus {
/// Implementation details
    var errorReason: String? {
        guard case let .failure(reason) = self else { return nil }
        return reason
    }
    
    /// Debug description of status
    var debugDescription: String {
        switch self {
        case .standby:
            return "Standby"
        case .progressing(let progress):
            return "Loading \(Int(progress * 100))%"
        case .finished:
            return "Completed"
        case .failure(let reason):
            return "Error: \(reason)"
        case .noConnection:
            return "No Connection"
        }
    }
}

// MARK: - Custom implementation Equatable

extension CluckFarmWebStatus {
    static func == (lhs: CluckFarmWebStatus, rhs: CluckFarmWebStatus) -> Bool {
        lhs.isEquivalent(to: rhs)
    }
}
