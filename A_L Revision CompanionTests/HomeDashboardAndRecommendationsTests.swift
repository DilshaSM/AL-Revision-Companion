import Foundation
import Testing
@testable import AL_Revision_Companion

struct HomeDashboardAndRecommendationsTests {

    @Test
    func weaknessContentUsesFallbackWhenWeakAreaIsMissing() {
        let content = HomeDashboardContent.dashboard(
            from: DashboardHomePayload(
                continueLearning: nil,
                todaysFocus: nil,
                weeklyProgress: DashboardWeeklyProgress(percent: 20, focusTimeMinutes: 30, activeDays: 2),
                weakArea: nil,
                recentSubjects: []
            ),
            for: nil,
            date: Date(timeIntervalSince1970: 0)
        )

        #expect(content.weakness.statusText == "No Data Yet")
        #expect(content.weakness.title.contains("Take a quiz"))
        #expect(content.weakness.metricValueText == "0%")
    }

    @Test
    func applyingLocalContinueLearningUsesWidgetSummaryWhenBackendDataIsEmpty() {
        let base = HomeDashboardContent.placeholder(for: nil)
        let emptyContinue = HomeDashboardContent(
            appTitle: base.appTitle,
            greetingLine: base.greetingLine,
            greetingHeadline: base.greetingHeadline,
            continueLearning: .init(
                eyebrow: "Continue Learning",
                title: "No lesson in progress",
                progress: 0,
                progressText: "0%",
                actionTitle: "Browse Lessons"
            ),
            todaysFocus: base.todaysFocus,
            quickToolsTitle: base.quickToolsTitle,
            quickTools: base.quickTools,
            weeklyProgress: base.weeklyProgress,
            weakness: base.weakness,
            recentSubjectsTitle: base.recentSubjectsTitle,
            recentSubjects: base.recentSubjects
        )
        let widgetSummary = WidgetSummaryEntity(
            continueTitle: "Trigonometric Functions II",
            continueSubtitle: "Pure Mathematics",
            continueProgressPercent: 64,
            continueLessonId: 77,
            continueTopicId: 88,
            continueSubjectId: 99
        )

        let updated = emptyContinue.applyingLocalContinueLearning(widgetSummary)

        #expect(updated.continueLearning.title == "Pure Mathematics:\nTrigonometric Functions II")
        #expect(updated.continueLearning.progressText == "64%")
        #expect(updated.continueLearning.lessonId == 77)
        #expect(updated.continueLearning.subjectId == 99)
    }

    @Test
    func recommendationsFilterToPreferredSubjectWhenAvailable() {
        let recommendations = [
            DashboardRecommendation(
                topicId: 1,
                topicTitle: "Organic Chemistry",
                topicSubtitle: "Mechanisms",
                subjectId: 100,
                subjectName: "Chemistry",
                priorityScore: 95,
                reasons: ["Weak score"],
                reason: "Weak score",
                estimatedMinutes: 15
            ),
            DashboardRecommendation(
                topicId: 2,
                topicTitle: "Vectors",
                topicSubtitle: "Forces",
                subjectId: 200,
                subjectName: "Physics",
                priorityScore: 72,
                reasons: ["Recent mistakes"],
                reason: "Recent mistakes",
                estimatedMinutes: 20
            )
        ]
        let preferred = ProgressTabContent.SubjectMastery(
            subjectID: 200,
            title: "Physics",
            subtitle: "Quiz mastery 0% • Lesson progress 0%",
            masteryPercent: 0,
            masteryText: "0%",
            progress: 0,
            progressText: "0%",
            iconName: "atom",
            accentStyle: .muted
        )

        let content = RecommendationsContent.build(
            recommendations: recommendations,
            preferredSubject: preferred
        )

        #expect(content.preferredSubjectID == 200)
        #expect(content.pathways.count == 1)
        #expect(content.pathways[0].subjectLine == "Physics")
        #expect(content.pathways[0].priority == .critical)
    }
}

