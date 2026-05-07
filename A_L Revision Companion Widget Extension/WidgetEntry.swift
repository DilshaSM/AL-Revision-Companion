import Foundation
import WidgetKit

struct WidgetEntry: TimelineEntry {
    let date: Date
    let summary: CachedWidgetSummary?

    static let placeholder = WidgetEntry(
        date: .now,
        summary: CachedWidgetSummary(
            continueLearning: CachedContinueLearning(
                title: "Trigonometric Functions II",
                subtitle: "Pure Mathematics",
                progressPercent: 64,
                lessonId: nil,
                topicId: nil,
                subjectId: nil
            ),
            todaysFocus: CachedTodaysFocus(
                title: "Reaction Mechanisms",
                subtitle: "Organic Chemistry",
                topicId: nil,
                subjectId: nil
            ),
            revisionProgress: CachedRevisionProgress(
                weeklyGoalPercent: 72,
                focusTimeMinutes: 180,
                activeDays: 4,
                chaptersCompleted: 9
            ),
            updatedAt: .now
        )
    )
}
