import Foundation
import Testing
@testable import AL_Revision_Companion

struct LessonQuizWidgetAndQuickRevisionTests {

    @Test
    func retryVersionClearsResumeAttemptAndSelections() {
        let attempt = QuizAttemptState(
            attemptId: 5,
            quizId: 9,
            status: "IN_PROGRESS",
            startedAt: Date(timeIntervalSince1970: 0),
            answeredCount: 1,
            questionCount: 2,
            progressPercent: 50,
            savedAnswers: [
                QuizSavedAnswer(questionId: 11, selectedOptionId: 101, isCorrect: nil, answeredAt: nil)
            ],
            topicId: 77,
            isResumed: true
        )
        let content = LessonQuizContent(
            id: 9,
            quizID: 9,
            subjectID: 1,
            lessonID: 2,
            topicID: 77,
            subjectTitle: "Physics",
            lessonTitle: "Motion",
            topicTitle: "Vectors",
            topicSubtitle: nil,
            quizTitle: "Vectors Quiz",
            quizDescription: nil,
            difficulty: nil,
            questions: [
                .init(
                    id: 11,
                    prompt: "Question 1",
                    options: [.init(id: 101, text: "A"), .init(id: 102, text: "B")],
                    selectedOptionID: 101
                )
            ],
            nextLesson: nil,
            resumeAttempt: attempt
        )

        let retry = content.retryVersion

        #expect(retry.resumeAttempt == nil)
        #expect(retry.questions.allSatisfy { $0.selectedOptionID == nil })
    }

    @Test
    func cachedWidgetSummaryBuildsDeepLinksWithIdentifiers() {
        let summary = CachedWidgetSummary(
            continueLearning: CachedContinueLearning(
                title: "Lesson",
                subtitle: "Subject",
                progressPercent: 80,
                lessonId: 12,
                topicId: 34,
                subjectId: 56
            ),
            todaysFocus: CachedTodaysFocus(
                title: "Topic",
                subtitle: "Reason",
                topicId: 78,
                subjectId: 90
            ),
            revisionProgress: CachedRevisionProgress(
                weeklyGoalPercent: 70,
                focusTimeMinutes: 120,
                activeDays: 4,
                chaptersCompleted: 8
            ),
            updatedAt: Date(timeIntervalSince1970: 0)
        )

        let continueURL = summary.continueLearningURL.absoluteString
        let focusURL = summary.todaysFocusURL.absoluteString

        #expect(continueURL.contains("academicatelier://continue-learning"))
        #expect(continueURL.contains("subjectId=56"))
        #expect(continueURL.contains("lessonId=12"))
        #expect(continueURL.contains("topicId=34"))
        #expect(focusURL.contains("academicatelier://recommendation"))
        #expect(focusURL.contains("subjectId=90"))
        #expect(focusURL.contains("topicId=78"))
    }

    @Test
    func quickRevisionTopicDetailMapsLabelsStylesAndSortsSections() {
        let detail = QuickRevisionTopicDetailContent(
            apiTopic: APIQuickRevisionTopicDetail(
                id: 1,
                title: "Kinematics",
                subtitle: "Motion",
                subjectId: 20,
                subjectName: "Physics",
                sections: [
                    APIQuickRevisionTopicSection(id: 2, sectionType: "FORMULA", title: "Second", content: "v = u + at", orderIndex: 2),
                    APIQuickRevisionTopicSection(id: 1, sectionType: "KEY_DEFINITION", title: "First", content: "Definition", orderIndex: 1),
                    APIQuickRevisionTopicSection(id: 3, sectionType: "QUICK_SUMMARY", title: "Third", content: "Summary", orderIndex: 3)
                ]
            )
        )

        #expect(detail.sections.map(\.id) == [1, 2, 3])
        #expect(detail.sections[0].labelText == "Key Definition")
        #expect(detail.sections[0].style == .definition)
        #expect(detail.sections[1].style == .formula)
        #expect(detail.sections[2].style == .summary)
    }
}

