import Foundation

struct QuizResultContent: Hashable {
    var id: Int
    var attemptID: Int
    var subjectTitle: String
    var lessonTitle: String
    var topicTitle: String
    var scorePercent: Int
    var scoreText: String
    var headline: String
    var message: String
    var correctCount: Int
    var incorrectCount: Int
    var timeTakenText: String
    var masteryLevel: String
    var subjectProgressText: String
    var completedLessonsText: String
    var studySessionText: String
    var submittedAtText: String?
    var nextLesson: SubjectLessonsContent.Lesson?
    var retryQuizContent: LessonQuizContent

    var nextTopicTitle: String? {
        nextLesson?.nextActionTitle
    }

    static func build(
        from quiz: LessonQuizContent,
        submission: SubmitQuizPayload
    ) -> QuizResultContent {
        QuizResultContent(
            id: submission.attempt.id,
            attemptID: submission.attempt.id,
            subjectTitle: quiz.subjectTitle,
            lessonTitle: quiz.lessonTitle,
            topicTitle: quiz.topicTitle,
            scorePercent: submission.attempt.scorePercent,
            scoreText: "\(submission.attempt.scorePercent)%",
            headline: headline(for: submission.attempt.scorePercent),
            message: message(for: quiz.topicTitle, masteryLevel: submission.attempt.masteryLevel),
            correctCount: submission.attempt.correctCount,
            incorrectCount: submission.attempt.incorrectCount,
            timeTakenText: durationText(seconds: submission.attempt.durationSeconds),
            masteryLevel: submission.attempt.masteryLevel,
            subjectProgressText: "\(submission.subjectProgress.progressPercent)%",
            completedLessonsText: "\(submission.subjectProgress.completedLessonCount) of \(submission.subjectProgress.totalLessonCount) lessons completed",
            studySessionText: "\(submission.studySession.durationMinutes) min \(submission.studySession.sessionType.lowercased()) session",
            submittedAtText: submittedAtText(from: submission.attempt.submittedAt),
            nextLesson: quiz.nextLesson,
            retryQuizContent: quiz.retryVersion
        )
    }
}

struct ReviewAnswersContent: Hashable {
    var attemptID: Int
    var subjectTitle: String
    var subtitle: String
    var scoreText: String
    var nextLesson: SubjectLessonsContent.Lesson?
    var recommendationText: String
    var questions: [ReviewQuestion]

    static func build(
        from payload: QuizAttemptReviewPayload,
        result: QuizResultContent
    ) -> ReviewAnswersContent {
        let questions = payload.reviewItems.enumerated().map { index, item in
            let selectedText = item.options.first(where: { $0.id == item.selectedOptionId })?.optionText ?? "No answer"
            let correctText = item.options.first(where: { $0.id == item.correctOptionId })?.optionText ?? "Unknown"
            return ReviewQuestion(
                id: item.questionId,
                index: index + 1,
                prompt: item.questionText,
                yourAnswer: selectedText,
                correctAnswer: correctText,
                explanation: item.explanation ?? "No explanation provided.",
                isCorrect: item.isCorrect
            )
        }

        let focusPrompt = questions.first(where: { !$0.isCorrect })?.prompt ?? result.topicTitle

        return ReviewAnswersContent(
            attemptID: payload.attemptId,
            subjectTitle: result.subjectTitle,
            subtitle: "Learn from your performance",
            scoreText: result.scoreText,
            nextLesson: result.nextLesson,
            recommendationText: "Focus on weaker areas like \(focusPrompt) before your next attempt.",
            questions: questions
        )
    }
}

extension ReviewAnswersContent {
    struct ReviewQuestion: Identifiable, Hashable {
        var id: Int
        var index: Int
        var prompt: String
        var yourAnswer: String
        var correctAnswer: String
        var explanation: String
        var isCorrect: Bool
    }

    var nextTopicTitle: String? {
        nextLesson?.nextActionTitle
    }
}

private extension QuizResultContent {
    static func headline(for scorePercent: Int) -> String {
        switch scorePercent {
        case 80...100:
            return "Strong Result"
        case 50..<80:
            return "Progress Made"
        default:
            return "Keep Building"
        }
    }

    static func message(for topicTitle: String, masteryLevel: String) -> String {
        switch masteryLevel.lowercased() {
        case "strong":
            return "You showed strong understanding in \(topicTitle)."
        case "average":
            return "You are building steady understanding in \(topicTitle)."
        default:
            return "Review \(topicTitle) and try again to improve your mastery."
        }
    }

    static func durationText(seconds: Int) -> String {
        let safeSeconds = max(seconds, 0)
        let minutes = safeSeconds / 60
        let remainingSeconds = safeSeconds % 60
        return "\(minutes)m \(String(format: "%02d", remainingSeconds))s"
    }

    static func submittedAtText(from date: Date?) -> String? {
        guard let date else { return nil }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
