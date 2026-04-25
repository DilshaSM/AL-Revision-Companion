import Foundation

struct SubjectsService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getSubjects() async throws -> [APISubject] {
        let payload: SubjectsPayload = try await client.send(
            path: "/subjects",
            method: "GET",
            requiresAuth: true
        )

        return payload.subjects
    }

    func getSubjectUnits(subjectID: Int) async throws -> APISubjectTree {
        let payload: SubjectUnitsPayload = try await client.send(
            path: "/subjects/\(subjectID)/units",
            method: "GET",
            requiresAuth: true
        )

        return payload.subject
    }

    func openLesson(lessonID: Int) async throws -> OpenLessonPayload {
        try await client.send(
            path: "/lessons/\(lessonID)/open",
            method: "POST",
            body: EmptyRequest(),
            requiresAuth: true
        )
    }

    func getTopicQuiz(topicID: Int) async throws -> TopicQuizPayload {
        try await client.send(
            path: "/topics/\(topicID)/quiz",
            method: "GET",
            requiresAuth: true
        )
    }

    func startQuiz(quizID: Int) async throws -> QuizStartPayload {
        try await client.send(
            path: "/quizzes/\(quizID)/start",
            method: "POST",
            body: EmptyRequest(),
            requiresAuth: true
        )
    }

    func submitQuiz(
        quizID: Int,
        attemptID: Int,
        answers: [SubmitQuizAnswerRequest]
    ) async throws -> SubmitQuizPayload {
        try await client.send(
            path: "/quizzes/\(quizID)/submit",
            method: "POST",
            body: SubmitQuizRequest(
                attemptId: attemptID,
                answers: answers
            ),
            requiresAuth: true
        )
    }

    func getAttemptResult(attemptID: Int) async throws -> QuizAttemptResultPayload {
        try await client.send(
            path: "/attempts/\(attemptID)/result",
            method: "GET",
            requiresAuth: true
        )
    }

    func getAttemptReview(attemptID: Int) async throws -> QuizAttemptReviewPayload {
        try await client.send(
            path: "/attempts/\(attemptID)/review",
            method: "GET",
            requiresAuth: true
        )
    }
}
