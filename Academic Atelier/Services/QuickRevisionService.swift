import Foundation

struct QuickRevisionService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getSubjects() async throws -> [APIQuickRevisionSubject] {
        let payload: QuickRevisionSubjectsPayload = try await client.send(
            path: "/quick-revision/subjects",
            method: "GET",
            requiresAuth: true
        )

        return payload.subjects
    }

    func getTopics(subjectID: Int) async throws -> APIQuickRevisionTopicsSubject {
        let payload: QuickRevisionTopicsPayload = try await client.send(
            path: "/quick-revision/subjects/\(subjectID)/topics",
            method: "GET",
            requiresAuth: true
        )

        return payload.subject
    }

    func getTopicDetail(topicID: Int) async throws -> APIQuickRevisionTopicDetail {
        let payload: QuickRevisionTopicDetailPayload = try await client.send(
            path: "/quick-revision/topics/\(topicID)",
            method: "GET",
            requiresAuth: true
        )

        return payload.topic
    }
}
