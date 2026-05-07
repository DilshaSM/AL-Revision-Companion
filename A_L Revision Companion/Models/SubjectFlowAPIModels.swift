import Foundation

struct SubjectsPayload: Decodable {
    let subjects: [APISubject]
}

struct APISubject: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let displayName: String
    let icon: String?
    let color: String?
    let orderIndex: Int
    let streamId: Int
}

struct SubjectUnitsPayload: Decodable {
    let subject: APISubjectTree
}

struct APISubjectTree: Decodable, Hashable {
    let id: Int
    let name: String
    let displayName: String
    let icon: String?
    let color: String?
    let units: [APISubjectUnit]
}

struct APISubjectUnit: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let orderIndex: Int
    let lessons: [APISubjectLesson]
}

struct APISubjectLesson: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let estimatedDurationMinutes: Int?
    let orderIndex: Int
    let isLockedByDefault: Bool
    let topics: [APISubjectTopic]
    let status: String
    let progressPercent: Int
    let isLocked: Bool
}

struct APISubjectTopic: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String?
    let estimatedDurationMinutes: Int?
    let orderIndex: Int
    let isActive: Bool
}

struct OpenLessonPayload: Decodable {
    let lessonProgress: UserLessonProgress
    let lesson: OpenLessonSummary?
}

struct UserLessonProgress: Decodable, Hashable {
    let lessonId: Int
    let status: String
    let progressPercent: Int
    let lastAccessedAt: Date?
}

struct OpenLessonSummary: Decodable, Hashable {
    let id: Int
    let title: String
    let subjectId: Int
    let subjectName: String
}

struct TopicQuizPayload: Decodable {
    let topic: QuizTopicSummary
    let quiz: TopicQuiz
}

struct QuizTopicSummary: Decodable, Hashable {
    let id: Int
    let title: String
    let subtitle: String?
    let lessonId: Int
    let subjectId: Int
    let subjectName: String
}

struct TopicQuiz: Decodable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let difficulty: String?
    let questionCount: Int
    let questions: [TopicQuizQuestion]
}

struct TopicQuizQuestion: Decodable, Hashable, Identifiable {
    let id: Int
    let questionText: String
    let orderIndex: Int
    let options: [TopicQuizOption]
}

struct TopicQuizOption: Decodable, Hashable, Identifiable {
    let id: Int
    let optionText: String
    let orderIndex: Int
}

struct QuizStartPayload: Decodable, Hashable {
    let attemptId: Int
    let quizId: Int
    let topicId: Int
    let startedAt: Date
}

struct SubmitQuizRequest: Encodable {
    let attemptId: Int
    let answers: [SubmitQuizAnswerRequest]
}

struct SubmitQuizAnswerRequest: Encodable, Hashable {
    let questionId: Int
    let selectedOptionId: Int?
}

struct SubmitQuizPayload: Decodable, Hashable {
    let attempt: SubmittedQuizAttempt
    let lessonProgress: UserLessonProgress
    let subjectProgress: SubjectProgressSummary
    let studySession: StudySessionSummary
}

struct SubmittedQuizAttempt: Decodable, Hashable {
    let id: Int
    let status: String
    let scorePercent: Int
    let correctCount: Int
    let incorrectCount: Int
    let durationSeconds: Int
    let masteryLevel: String
    let submittedAt: Date?
}

struct SubjectProgressSummary: Decodable, Hashable {
    let subjectId: Int
    let progressPercent: Int
    let completedLessonCount: Int
    let totalLessonCount: Int
    let lastActiveAt: Date?
}

struct StudySessionSummary: Decodable, Hashable {
    let sessionType: String
    let subjectId: Int
    let topicId: Int
    let durationMinutes: Int
}

struct QuizAttemptResultPayload: Decodable, Hashable {
    let attempt: SubmittedQuizAttempt
    let quiz: AttemptQuizSummary
}

struct AttemptQuizSummary: Decodable, Hashable {
    let id: Int
    let title: String
    let topicId: Int
    let topicTitle: String
    let subjectId: Int
    let subjectName: String
}

struct QuizAttemptReviewPayload: Decodable, Hashable {
    let attemptId: Int
    let reviewItems: [QuizAttemptReviewItem]
}

struct QuizAttemptReviewItem: Decodable, Hashable {
    let questionId: Int
    let questionText: String
    let explanation: String?
    let selectedOptionId: Int?
    let correctOptionId: Int?
    let isCorrect: Bool
    let options: [QuizAttemptReviewOption]
}

struct QuizAttemptReviewOption: Decodable, Hashable, Identifiable {
    let id: Int
    let optionText: String
    let isCorrect: Bool
}
