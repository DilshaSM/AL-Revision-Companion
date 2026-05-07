import Foundation
import SwiftData

@Model
final class WidgetSummaryEntity {
    @Attribute(.unique) var id: String

    var continueTitle: String?
    var continueSubtitle: String?
    var continueProgressPercent: Int
    var continueLessonId: Int?
    var continueTopicId: Int?
    var continueSubjectId: Int?

    var focusTitle: String?
    var focusSubtitle: String?
    var focusTopicId: Int?
    var focusSubjectId: Int?

    var weeklyGoalPercent: Int
    var focusTimeMinutes: Int
    var activeDays: Int
    var chaptersCompleted: Int

    var updatedAt: Date

    init(
        id: String = "latest",
        continueTitle: String? = nil,
        continueSubtitle: String? = nil,
        continueProgressPercent: Int = 0,
        continueLessonId: Int? = nil,
        continueTopicId: Int? = nil,
        continueSubjectId: Int? = nil,
        focusTitle: String? = nil,
        focusSubtitle: String? = nil,
        focusTopicId: Int? = nil,
        focusSubjectId: Int? = nil,
        weeklyGoalPercent: Int = 0,
        focusTimeMinutes: Int = 0,
        activeDays: Int = 0,
        chaptersCompleted: Int = 0,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.continueTitle = continueTitle
        self.continueSubtitle = continueSubtitle
        self.continueProgressPercent = continueProgressPercent
        self.continueLessonId = continueLessonId
        self.continueTopicId = continueTopicId
        self.continueSubjectId = continueSubjectId
        self.focusTitle = focusTitle
        self.focusSubtitle = focusSubtitle
        self.focusTopicId = focusTopicId
        self.focusSubjectId = focusSubjectId
        self.weeklyGoalPercent = weeklyGoalPercent
        self.focusTimeMinutes = focusTimeMinutes
        self.activeDays = activeDays
        self.chaptersCompleted = chaptersCompleted
        self.updatedAt = updatedAt
    }
}

extension WidgetSummaryEntity {
    convenience init(payload: WidgetSummaryPayload) {
        let widgets = payload.widgets

        self.init(
            continueTitle: widgets.continueLearning?.title,
            continueSubtitle: widgets.continueLearning?.subtitle,
            continueProgressPercent: widgets.continueLearning?.progressPercent ?? 0,
            continueLessonId: widgets.continueLearning?.lessonId,
            continueTopicId: widgets.continueLearning?.topicId,
            continueSubjectId: widgets.continueLearning?.subjectId,
            focusTitle: widgets.todaysFocus?.title,
            focusSubtitle: widgets.todaysFocus?.subtitle,
            focusTopicId: widgets.todaysFocus?.topicId,
            focusSubjectId: widgets.todaysFocus?.subjectId,
            weeklyGoalPercent: widgets.revisionProgress.weeklyGoalPercent,
            focusTimeMinutes: widgets.revisionProgress.focusTimeMinutes,
            activeDays: widgets.revisionProgress.activeDays,
            chaptersCompleted: widgets.revisionProgress.chaptersCompleted,
            updatedAt: payload.updatedAt
        )
    }
}
