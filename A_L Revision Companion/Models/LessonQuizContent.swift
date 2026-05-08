import Foundation

struct LessonQuizContent: Hashable {
    var id: Int
    var quizID: Int
    var subjectID: Int
    var lessonID: Int
    var topicID: Int
    var subjectTitle: String
    var lessonTitle: String
    var topicTitle: String
    var topicSubtitle: String?
    var quizTitle: String
    var quizDescription: String?
    var difficulty: String?
    var questions: [Question]
    var nextLesson: SubjectLessonsContent.Lesson?
    var resumeAttempt: QuizAttemptState?

    static func build(
        from payload: TopicQuizPayload,
        lesson: SubjectLessonsContent.Lesson,
        nextLesson: SubjectLessonsContent.Lesson?
    ) -> LessonQuizContent {
        let savedAnswersByQuestionID = Dictionary(
            uniqueKeysWithValues: (payload.resumeAttempt?.savedAnswers ?? []).map {
                ($0.questionId, $0.selectedOptionId)
            }
        )

        return LessonQuizContent(
            id: payload.quiz.id,
            quizID: payload.quiz.id,
            subjectID: payload.topic.subjectId,
            lessonID: payload.topic.lessonId,
            topicID: payload.topic.id,
            subjectTitle: payload.topic.subjectName,
            lessonTitle: lesson.title,
            topicTitle: payload.topic.title,
            topicSubtitle: payload.topic.subtitle,
            quizTitle: payload.quiz.title,
            quizDescription: payload.quiz.description,
            difficulty: payload.quiz.difficulty,
            questions: payload.quiz.questions
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { question in
                    Question(
                        id: question.id,
                        prompt: question.questionText,
                        options: question.options
                            .sorted { $0.orderIndex < $1.orderIndex }
                            .map { Option(id: $0.id, text: $0.optionText) },
                        selectedOptionID: savedAnswersByQuestionID[question.id] ?? nil
                    )
                },
            nextLesson: nextLesson,
            resumeAttempt: payload.resumeAttempt
        )
    }
}

extension LessonQuizContent {
    struct Question: Identifiable, Hashable {
        var id: Int
        var prompt: String
        var options: [Option]
        var selectedOptionID: Int?
    }

    struct Option: Identifiable, Hashable {
        var id: Int
        var text: String
    }
}

extension LessonQuizContent {
    var retryVersion: LessonQuizContent {
        var retry = self
        retry.resumeAttempt = nil
        retry.questions = retry.questions.map { question in
            var question = question
            question.selectedOptionID = nil
            return question
        }
        return retry
    }
}
