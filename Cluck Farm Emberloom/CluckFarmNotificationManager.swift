import Foundation
import UserNotifications
import UIKit

// MARK: - Manager Implementation Implementation Cluck Farm

@MainActor
class CluckFarmNotificationManager: NSObject, ObservableObject {
    static let shared = CluckFarmNotificationManager()
    
    @Published var notificationsEnabled: Bool = false
    @Published var dailyRemindersEnabled: Bool = false
    @Published var achievementNotificationsEnabled: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        loadNotificationSettings()
    }
    
    private func loadNotificationSettings() {
        notificationsEnabled = userDefaults.bool(forKey: "CluckFarmNotificationsEnabled")
        dailyRemindersEnabled = userDefaults.bool(forKey: "CluckFarmDailyReminders")
        achievementNotificationsEnabled = userDefaults.bool(forKey: "CluckFarmAchievementNotifications")
    }
    
    func saveNotificationSettings() {
        userDefaults.set(notificationsEnabled, forKey: "CluckFarmNotificationsEnabled")
        userDefaults.set(dailyRemindersEnabled, forKey: "CluckFarmDailyReminders")
        userDefaults.set(achievementNotificationsEnabled, forKey: "CluckFarmAchievementNotifications")
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            self.notificationsEnabled = granted
            self.saveNotificationSettings()
            return granted
        } catch {
            return false
        }
    }
    
    func scheduleDailyReminder() {
        guard notificationsEnabled && dailyRemindersEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Cluck Farm: Emberloom"
        content.body = "Vashi kury skuchayut! Proverte fermu i soberite yaytsa."
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 19 // 7 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "CluckFarmDailyReminder", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }
    
    func scheduleAchievementNotification(title: String, message: String) {
        guard notificationsEnabled && achievementNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "CluckFarmAchievement"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule achievement notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func cancelDailyReminders() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["CluckFarmDailyReminder"])
    }
}

extension CluckFarmNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        if response.notification.request.content.categoryIdentifier == "CluckFarmAchievement" {
            // Navigate to achievements screen
        }
        completionHandler()
    }
}
