import Foundation

struct RecallToolsService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getFlashcardDecks() async throws -> [APIFlashcardDeckSummary] {
        let payload: FlashcardDecksPayload = try await client.send(
            path: "/flashcards/decks",
            method: "GET",
            requiresAuth: true
        )

        return payload.decks
    }

    func startFlashcardSession(deckID: Int) async throws -> FlashcardSessionStartPayload {
        try await client.send(
            path: "/flashcards/decks/\(deckID)/start",
            method: "POST",
            body: EmptyRequest(),
            requiresAuth: true
        )
    }

    func respondToFlashcardSession(
        sessionID: Int,
        flashcardID: Int,
        responseType: String
    ) async throws -> FlashcardSessionRespondPayload {
        try await client.send(
            path: "/flashcards/sessions/\(sessionID)/respond",
            method: "POST",
            body: FlashcardSessionResponseRequest(
                flashcardId: flashcardID,
                responseType: responseType
            ),
            requiresAuth: true
        )
    }

    func getAudioNotes() async throws -> [APIAudioNoteSummary] {
        let payload: AudioNotesPayload = try await client.send(
            path: "/audio-notes",
            method: "GET",
            requiresAuth: true
        )

        return payload.audioNotes
    }

    func getAudioNoteDetail(audioNoteID: Int) async throws -> APIAudioNoteDetail {
        let payload: AudioNoteDetailPayload = try await client.send(
            path: "/audio-notes/\(audioNoteID)",
            method: "GET",
            requiresAuth: true
        )

        return payload.audioNote
    }

    func saveAudioNoteProgress(
        audioNoteID: Int,
        lastPositionSeconds: Int,
        playbackSpeed: Double,
        durationMinutes: Int,
        ended: Bool
    ) async throws -> SaveAudioNoteProgressPayload {
        try await client.send(
            path: "/audio-notes/\(audioNoteID)/progress",
            method: "POST",
            body: SaveAudioNoteProgressRequest(
                lastPositionSeconds: lastPositionSeconds,
                playbackSpeed: playbackSpeed,
                durationMinutes: durationMinutes,
                ended: ended
            ),
            requiresAuth: true
        )
    }
}
