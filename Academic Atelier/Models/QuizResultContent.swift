import Foundation

struct QuizResultContent: Hashable {
    var id: String
    var subjectTitle: String
    var lessonTitle: String
    var scorePercent: Int
    var scoreText: String
    var headline: String
    var message: String
    var correctCount: Int
    var incorrectCount: Int
    var timeTakenText: String
    var nextTopicTitle: String?
    var retryQuizContent: LessonQuizContent
    var nextTopicQuizContent: LessonQuizContent?
    var reviewContent: ReviewAnswersContent
    var topicBreakdown: [TopicBreakdown]

    static func build(
        from quiz: LessonQuizContent,
        selectedOptionIDsByQuestionID: [String: String],
        nextTopicQuizContent: LessonQuizContent?
    ) -> QuizResultContent {
        let questions = hydratedQuestions(from: quiz, selections: selectedOptionIDsByQuestionID)
        let correctCount = questions.filter(\.isCorrect).count
        let totalCount = max(questions.count, 1)
        let incorrectCount = questions.count - correctCount
        let scorePercent = Int((Double(correctCount) / Double(totalCount) * 100).rounded())
        let reviewContent = ReviewAnswersContent.build(
            from: quiz,
            questions: questions,
            scorePercent: scorePercent,
            nextTopicQuizContent: nextTopicQuizContent
        )

        return .init(
            id: quiz.id,
            subjectTitle: quiz.subjectTitle,
            lessonTitle: quiz.lessonTitle,
            scorePercent: scorePercent,
            scoreText: "\(scorePercent)%",
            headline: headline(for: scorePercent),
            message: message(for: quiz.lessonTitle, scorePercent: scorePercent),
            correctCount: correctCount,
            incorrectCount: incorrectCount,
            timeTakenText: estimatedDurationText(questionCount: questions.count),
            nextTopicTitle: nextTopicQuizContent?.lessonTitle,
            retryQuizContent: quiz.retryVersion,
            nextTopicQuizContent: nextTopicQuizContent,
            reviewContent: reviewContent,
            topicBreakdown: topicBreakdown(from: questions)
        )
    }
}

extension QuizResultContent {
    struct TopicBreakdown: Identifiable, Hashable {
        var id: String
        var title: String
        var questionCount: Int
        var masteryPercent: Int
        var iconSystemName: String
        var tint: TopicTint
    }

    enum TopicTint: Hashable {
        case green
        case blue
    }
}

struct ReviewAnswersContent: Hashable {
    var id: String
    var subjectTitle: String
    var subtitle: String
    var scoreText: String
    var nextTopicTitle: String?
    var nextTopicQuizContent: LessonQuizContent?
    var recommendationText: String
    var questions: [ReviewQuestion]
}

extension ReviewAnswersContent {
    struct ReviewQuestion: Identifiable, Hashable {
        var id: String
        var index: Int
        var prompt: String
        var yourAnswer: String
        var correctAnswer: String
        var explanation: String
        var isCorrect: Bool
    }

    fileprivate static func build(
        from quiz: LessonQuizContent,
        questions: [QuizResultResolvedQuestion],
        scorePercent: Int,
        nextTopicQuizContent: LessonQuizContent?
    ) -> ReviewAnswersContent {
        let weakestTopic = questions
            .reduce(into: [String: (correct: Int, total: Int)]()) { partial, question in
                var value = partial[question.topicTitle] ?? (0, 0)
                value.total += 1
                if question.isCorrect { value.correct += 1 }
                partial[question.topicTitle] = value
            }
            .min { lhs, rhs in
                Double(lhs.value.correct) / Double(max(lhs.value.total, 1)) < Double(rhs.value.correct) / Double(max(rhs.value.total, 1))
            }?
            .key ?? quiz.lessonTitle

        return .init(
            id: quiz.id,
            subjectTitle: quiz.subjectTitle,
            subtitle: "Learn from your performance",
            scoreText: "\(scorePercent)%",
            nextTopicTitle: nextTopicQuizContent?.lessonTitle,
            nextTopicQuizContent: nextTopicQuizContent,
            recommendationText: "Focus on weak areas like \(weakestTopic) to boost your performance.",
            questions: questions.enumerated().map { index, question in
                .init(
                    id: question.id,
                    index: index + 1,
                    prompt: question.prompt,
                    yourAnswer: question.selectedAnswerText,
                    correctAnswer: question.correctAnswerText,
                    explanation: question.explanation,
                    isCorrect: question.isCorrect
                )
            }
        )
    }
}

private struct QuizResultResolvedQuestion: Hashable {
    var id: String
    var prompt: String
    var topicTitle: String
    var selectedAnswerText: String
    var correctAnswerText: String
    var explanation: String
    var isCorrect: Bool
}

private extension QuizResultContent {
    static func hydratedQuestions(
        from quiz: LessonQuizContent,
        selections: [String: String]
    ) -> [QuizResultResolvedQuestion] {
        quiz.questions.map { question in
            let selectedOptionID = selections[question.id] ?? question.selectedOptionID ?? question.correctOptionID
            let selectedAnswerText = question.options.first(where: { $0.id == selectedOptionID })?.text ?? "No answer"
            let correctAnswerText = question.options.first(where: { $0.id == question.correctOptionID })?.text ?? "Unknown"
            return .init(
                id: question.id,
                prompt: question.prompt,
                topicTitle: question.topicTitle,
                selectedAnswerText: selectedAnswerText,
                correctAnswerText: correctAnswerText,
                explanation: question.explanation,
                isCorrect: selectedOptionID == question.correctOptionID
            )
        }
    }

    static func topicBreakdown(from questions: [QuizResultResolvedQuestion]) -> [TopicBreakdown] {
        let grouped = Dictionary(grouping: questions, by: \.topicTitle)
        return grouped.keys.sorted().enumerated().map { index, key in
            let values = grouped[key] ?? []
            let correctCount = values.filter(\.isCorrect).count
            let masteryPercent = Int((Double(correctCount) / Double(max(values.count, 1)) * 100).rounded())
            return .init(
                id: key.lowercased().replacingOccurrences(of: " ", with: "-"),
                title: key,
                questionCount: values.count,
                masteryPercent: masteryPercent,
                iconSystemName: index == 0 ? "sparkles" : (index == 1 ? "bolt.fill" : "book.closed"),
                tint: masteryPercent == 100 ? .green : .blue
            )
        }
    }

    static func headline(for scorePercent: Int) -> String {
        switch scorePercent {
        case 90...100:
            return "Excellent Work!"
        case 75..<90:
            return "Strong Progress!"
        case 60..<75:
            return "Good Effort!"
        default:
            return "Keep Going!"
        }
    }

    static func message(for lessonTitle: String, scorePercent: Int) -> String {
        switch scorePercent {
        case 90...100:
            return "Outstanding command of \(lessonTitle)."
        case 75..<90:
            return "Strong grasp of \(lessonTitle)."
        case 60..<75:
            return "You are building confidence in \(lessonTitle)."
        default:
            return "Review the weaker ideas in \(lessonTitle) and try again."
        }
    }

    static func estimatedDurationText(questionCount: Int) -> String {
        let totalSeconds = max(questionCount * 38, 120)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(String(format: "%02d", seconds))s"
    }
}
