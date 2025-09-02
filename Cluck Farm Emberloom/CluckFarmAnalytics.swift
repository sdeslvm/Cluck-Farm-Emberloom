import Foundation
import UIKit

// MARK: - Аналитика для Cluck Farm

class CluckFarmAnalytics: ObservableObject {
    static let shared = CluckFarmAnalytics()
    
    @Published var sessionStartTime: Date = Date()
    @Published var gamePlayTime: TimeInterval = 0
    @Published var totalLaunches: Int = 0
    @Published var crashReports: [CluckFarmCrashReport] = []
    
    private let userDefaults = UserDefaults.standard
    private let securityLayer = CluckFarmSecurityLayer.shared
    
    struct CluckFarmCrashReport: Codable {
        let timestamp: Date
        let errorDescription: String
        let stackTrace: String
        let deviceInfo: CluckFarmDeviceInfo
    }
    
    struct CluckFarmDeviceInfo: Codable {
        let deviceModel: String
        let systemVersion: String
        let appVersion: String
        let memoryUsage: UInt64
        
        init() {
            self.deviceModel = UIDevice.current.model
            self.systemVersion = UIDevice.current.systemVersion
            self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            self.memoryUsage = CluckFarmAnalytics.getMemoryUsage()
        }
    }
    
    private init() {
        loadAnalyticsData()
        incrementLaunchCount()
    }
    
    private func loadAnalyticsData() {
        totalLaunches = userDefaults.integer(forKey: "CluckFarmTotalLaunches")
        
        if let crashData = userDefaults.data(forKey: "CluckFarmCrashReports"),
           let reports = try? JSONDecoder().decode([CluckFarmCrashReport].self, from: crashData) {
            crashReports = reports
        }
    }
    
    private func incrementLaunchCount() {
        totalLaunches += 1
        userDefaults.set(totalLaunches, forKey: "CluckFarmTotalLaunches")
    }
    
    func recordGameSession(duration: TimeInterval) {
        gamePlayTime += duration
        userDefaults.set(gamePlayTime, forKey: "CluckFarmGamePlayTime")
    }
    
    func recordCrash(error: Error, stackTrace: String = "") {
        let crashReport = CluckFarmCrashReport(
            timestamp: Date(),
            errorDescription: error.localizedDescription,
            stackTrace: stackTrace,
            deviceInfo: CluckFarmDeviceInfo()
        )
        
        crashReports.append(crashReport)
        
        // Keep only last 10 crash reports
        if crashReports.count > 10 {
            crashReports.removeFirst()
        }
        
        saveCrashReports()
    }
    
    private func saveCrashReports() {
        if let data = try? JSONEncoder().encode(crashReports) {
            userDefaults.set(data, forKey: "CluckFarmCrashReports")
        }
    }
    
    static func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    func generateAnalyticsReport() -> String {
        return """
        Cluck Farm Analytics Report
        ==========================
        Total Launches: \(totalLaunches)
        Total Play Time: \(String(format: "%.1f", gamePlayTime)) seconds
        Session Start: \(sessionStartTime)
        Crash Reports: \(crashReports.count)
        Memory Usage: \(CluckFarmAnalytics.getMemoryUsage() / 1024 / 1024) MB
        """
    }
}
