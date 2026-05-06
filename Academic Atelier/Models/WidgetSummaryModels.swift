import Foundation

struct CachedWidgetSummary: Codable {
    let continueLearning: CachedContinueLearning?
    let todaysFocus: CachedTodaysFocus?
    let revisionProgress: CachedRevisionProgress
    let updatedAt: Date
}

struct CachedContinueLearning: Codable {
    let title: String
    let subtitle: String
    let progressPercent: Int
    let lessonId: Int?
    let topicId: Int?
    let subjectId: Int?
}

struct CachedTodaysFocus: Codable {
    let title: String
    let subtitle: String
    let topicId: Int?
    let subjectId: Int?
}

struct CachedRevisionProgress: Codable {
    let weeklyGoalPercent: Int
    let focusTimeMinutes: Int
    let activeDays: Int
    let chaptersCompleted: Int
}
