import Foundation

struct RevisionNotificationScheduler {
    private let notificationService: NotificationService

    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService
    }

    func rescheduleNotifications(
        isEnabled: Bool,
        homePayload: DashboardHomePayload?
    ) async throws {
        notificationService.cancelRevisionNotifications()

        guard isEnabled else {
            return
        }

        let granted = try await notificationService.requestAuthorizationIfNeeded()

        guard granted else {
            return
        }

        try await notificationService.scheduleDailyRevisionReminder()

        if let continueLearning = homePayload?.continueLearning {
            try await notificationService.scheduleContinueLearningReminder(
                title: continueLearning.topicTitle ?? continueLearning.lessonTitle,
                subjectName: continueLearning.subjectName
            )
        }

        if let todaysFocus = homePayload?.todaysFocus {
            try await notificationService.scheduleTodaysFocusReminder(
                topicTitle: todaysFocus.topicTitle,
                reason: todaysFocus.reason
            )
        }

        if let weakArea = homePayload?.weakArea {
            try await notificationService.scheduleWeakAreaReminder(
                topicTitle: weakArea.title,
                subjectName: weakArea.subjectName
            )
        }
    }
}
