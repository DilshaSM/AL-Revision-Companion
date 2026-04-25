import Foundation

struct APIResponse<Payload: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: Payload?
}

struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String
}

struct EmptyPayload: Decodable {}
struct EmptyRequest: Encodable {}

struct AuthPayload: Decodable {
    let user: User
    let token: String
    let requiresStreamSelection: Bool
}

struct ForgotPasswordPayload: Decodable {
    let email: String
    let expiresAt: String
    let sent: Bool
}

struct VerifyResetCodePayload: Decodable {
    let email: String
    let verified: Bool
}

struct ResetPasswordPayload: Decodable {
    let email: String
    let reset: Bool
}

struct LogoutPayload: Decodable {
    let loggedOut: Bool
}

struct CurrentUserPayload: Decodable {
    let user: User
}

struct StreamsPayload: Decodable {
    let streams: [Stream]
}

struct StreamSelectionPayload: Decodable {
    let user: User
    let requiresStreamSelection: Bool
}

struct DashboardHomePayload: Decodable {
    let continueLearning: DashboardContinueLearning?
    let todaysFocus: DashboardRecommendation?
    let weeklyProgress: DashboardWeeklyProgress
    let weakArea: DashboardWeakArea?
    let recentSubjects: [DashboardRecentSubject]
}

struct DashboardContinueLearning: Decodable, Hashable {
    let lessonId: Int
    let lessonTitle: String
    let progressPercent: Int
    let subjectId: Int
    let subjectName: String
    let topicId: Int?
    let topicTitle: String?
    let lastAccessedAt: Date
}

struct DashboardRecommendation: Decodable, Hashable {
    let topicId: Int
    let topicTitle: String
    let topicSubtitle: String?
    let subjectId: Int
    let subjectName: String
    let priorityScore: Int
    let reasons: [String]
    let reason: String
    let estimatedMinutes: Int
}

struct DashboardWeeklyProgress: Decodable, Hashable {
    let percent: Int
    let focusTimeMinutes: Int
    let activeDays: Int
}

struct DashboardWeakArea: Decodable, Hashable {
    let topicId: Int
    let title: String
    let subjectId: Int
    let subjectName: String
    let averageScore: Int
    let masteryLevel: String
}

struct DashboardRecentSubject: Decodable, Hashable {
    let subjectId: Int
    let subjectName: String
    let color: String?
    let icon: String?
    let lastAccessedAt: Date
}

struct WidgetSummaryPayload: Decodable {
    let widgets: WidgetSummaryWidgets
    let recommendations: [DashboardRecommendation]
    let updatedAt: Date
}

struct WidgetSummaryWidgets: Decodable, Hashable {
    let continueLearning: WidgetContinueLearning?
    let todaysFocus: WidgetTodaysFocus?
    let revisionProgress: WidgetRevisionProgress
}

struct WidgetContinueLearning: Decodable, Hashable {
    let title: String
    let subtitle: String
    let progressPercent: Int
    let lessonId: Int
    let topicId: Int?
    let subjectId: Int
}

struct WidgetTodaysFocus: Decodable, Hashable {
    let title: String
    let subtitle: String
    let topicId: Int
    let subjectId: Int
    let priorityScore: Int
}

struct WidgetRevisionProgress: Decodable, Hashable {
    let weeklyGoalPercent: Int
    let focusTimeMinutes: Int
    let activeDays: Int
    let chaptersCompleted: Int
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let fullName: String
    let email: String
    let password: String
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct VerifyResetCodeRequest: Encodable {
    let email: String
    let code: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let newPassword: String
}

struct SelectStreamRequest: Encodable {
    let streamId: Int
}
