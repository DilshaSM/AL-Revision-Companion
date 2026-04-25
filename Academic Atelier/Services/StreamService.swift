import Foundation

struct StreamService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getStreams() async throws -> [Stream] {
        let payload: StreamsPayload = try await client.send(
            path: "/streams",
            method: "GET",
            requiresAuth: true
        )

        return payload.streams
    }

    func selectStream(streamID: Int) async throws -> StreamSelectionPayload {
        try await client.send(
            path: "/users/me/stream",
            method: "PUT",
            body: SelectStreamRequest(streamId: streamID),
            requiresAuth: true
        )
    }
}
