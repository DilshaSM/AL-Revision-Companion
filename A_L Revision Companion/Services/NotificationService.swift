import Foundation
import UserNotifications

struct NotificationService {
    static let shared = NotificationService()

    private init() {}

    enum Identifier {
        static let dailyRevision = "daily_revision_reminder"
        static let continueLearning = "continue_learning_reminder"
        static let todaysFocus = "todays_focus_reminder"
        static let weakArea = "weak_area_reminder"
    }

    func requestAuthorizationIfNeeded() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        @unknown default:
            return false
        }
    }

    func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { (continuation: CheckedContinuation<UNNotificationSettings, Never>) in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    func cancelRevisionNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                Identifier.dailyRevision,
                Identifier.continueLearning,
                Identifier.todaysFocus,
                Identifier.weakArea
            ]
        )
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleDailyRevisionReminder(hour: Int = 19, minute: Int = 0) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Revision Reminder"
        content.body = "Time to revise your A/L subjects today."
        content.sound = .default
        content.categoryIdentifier = "REVISION_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifier.dailyRevision,
            content: content,
            trigger: trigger
        )

        try await add(request)
    }

    func scheduleContinueLearningReminder(
        title: String,
        subjectName: String?,
        hour: Int = 08,
        minute: Int = 45
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Continue Learning"
        content.body = subjectName.map {
            "Continue \(title) in \($0)."
        } ?? "Continue \(title)."
        content.sound = .default
        content.categoryIdentifier = "CONTINUE_LEARNING"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifier.continueLearning,
            content: content,
            trigger: trigger
        )

        try await add(request)
    }

    func scheduleTodaysFocusReminder(
        topicTitle: String,
        reason: String?,
        hour: Int = 07,
        minute: Int = 06
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Today’s Focus"
        content.body = reason.map {
            "\(topicTitle) — \($0)"
        } ?? "Spend 15 minutes revising \(topicTitle)."
        content.sound = .default
        content.categoryIdentifier = "TODAYS_FOCUS"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifier.todaysFocus,
            content: content,
            trigger: trigger
        )

        try await add(request)
    }

    func scheduleWeakAreaReminder(
        topicTitle: String,
        subjectName: String?,
        hour: Int = 07,
        minute: Int = 07
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Weak Area Reminder"
        content.body = subjectName.map {
            "Revise \(topicTitle) in \($0). This is one of your weaker areas."
        } ?? "Revise \(topicTitle). This is one of your weaker areas."
        content.sound = .default
        content.categoryIdentifier = "WEAK_AREA"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifier.weakArea,
            content: content,
            trigger: trigger
        )

        try await add(request)
    }

    private func add(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
