import Foundation
import SwiftUI
import WebKit

// MARK: - Implementation

/// Implementation details
protocol CluckFarmLoadStateRepresentable {
    var type: CluckFarmLoadState.StateType { get }
    var percent: Double? { get }
    var error: String? { get }

    func isEqual(to other: Self) -> Bool
}

// MARK: - Implementation Implementation Implementation Implementation

/// Implementation details
struct CluckFarmLoadState: Equatable, CluckFarmLoadStateRepresentable {
    // MARK: - Implementation Implementation Implementation

/// Implementation details
    enum StateType: Int, CaseIterable {
        case idle = 0
        case progress
        case success
        case error
        case offline

/// Implementation details
        var description: String {
            switch self {
            case .idle: return "Ozhidanie"
            case .progress: return "Loading"
            case .success: return "Uspeshno"
            case .error: return "Error"
            case .offline: return "Net connection"
            }
        }
    }

    // MARK: - Properties

    let type: StateType
    let percent: Double?
    let error: String?

    // MARK: - Implementation Implementation

/// Implementation details
    static func idle() -> CluckFarmLoadState {
        CluckFarmLoadState(type: .idle, percent: nil, error: nil)
    }

/// Implementation details
    static func progress(_ percent: Double) -> CluckFarmLoadState {
        CluckFarmLoadState(type: .progress, percent: percent, error: nil)
    }

/// Implementation details
    static func success() -> CluckFarmLoadState {
        CluckFarmLoadState(type: .success, percent: nil, error: nil)
    }

/// Implementation details
    static func error(_ err: String) -> CluckFarmLoadState {
        CluckFarmLoadState(type: .error, percent: nil, error: err)
    }

/// Implementation details
    static func offline() -> CluckFarmLoadState {
        CluckFarmLoadState(type: .offline, percent: nil, error: nil)
    }

// MARK: - Methods

/// Implementation details
    func isEqual(to other: CluckFarmLoadState) -> Bool {
        guard type == other.type else { return false }

        switch type {
        case .progress:
            return percent == other.percent
        case .error:
            return error == other.error
        default:
            return true
        }
    }

    // MARK: - Implementation Equatable

    static func == (lhs: CluckFarmLoadState, rhs: CluckFarmLoadState) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

// MARK: - Extensions Implementation Implementation Implementation

extension CluckFarmLoadState {
/// Implementation details
    var isLoading: Bool {
        type == .progress
    }

/// Implementation details
    var isSuccessful: Bool {
        type == .success
    }

/// Implementation details
    var hasError: Bool {
        type == .error
    }
}

// MARK: - Implementation Implementation Implementation

extension CluckFarmLoadState: CustomStringConvertible {
/// Implementation details
    var description: String {
        switch type {
        case .idle: return "State: Ozhidanie"
        case .progress: return "State: Loading (\(percent?.formatted() ?? "0")%)"
        case .success: return "State: Uspeshno"
        case .error: return "State: Error (\(error ?? "Neizvestnaya error"))"
        case .offline: return "State: Net connection"
        }
    }
}
