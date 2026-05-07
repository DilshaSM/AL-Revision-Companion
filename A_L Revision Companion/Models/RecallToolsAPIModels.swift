import Foundation

struct FlashcardDecksPayload: Decodable {
    let decks: [APIFlashcardDeckSummary]
}

struct APIFlashcardDeckSummary: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let cardCount: Int
    let subjectId: Int
    let subjectName: String
    let topicId: Int
}

struct FlashcardSessionStartPayload: Decodable {
    let sessionId: Int
    let deck: APIFlashcardDeckSession
}

struct APIFlashcardDeckSession: Decodable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let cardCount: Int
    let cards: [APIFlashcardCard]
}

struct APIFlashcardCard: Decodable, Hashable, Identifiable {
    let id: Int
    let frontText: String
    let backText: String
    let hintText: String?
    let orderIndex: Int
}

struct FlashcardSessionResponseRequest: Encodable {
    let flashcardId: Int
    let responseType: String
}

struct FlashcardSessionRespondPayload: Decodable {
    let response: APIFlashcardResponseRecord
    let session: APIFlashcardSessionState
}

struct APIFlashcardResponseRecord: Decodable, Hashable {
    let id: Int
    let sessionId: Int
    let flashcardId: Int
    let responseType: String
    let respondedAt: Date
}

struct APIFlashcardSessionState: Decodable, Hashable {
    let id: Int
    let knownCount: Int
    let reviewAgainCount: Int
    let currentCardIndex: Int
    let completedAt: Date?
    let isCompleted: Bool
}

struct AudioNotesPayload: Decodable {
    let audioNotes: [APIAudioNoteSummary]
}

struct APIAudioNoteSummary: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let durationSeconds: Int
    let topicId: Int
    let subjectId: Int
    let subjectName: String
    let thumbnailUrl: String?
}

struct AudioNoteDetailPayload: Decodable {
    let audioNote: APIAudioNoteDetail
}

struct APIAudioNoteDetail: Decodable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let durationSeconds: Int
    let audioUrl: String
    let playbackTopicId: Int
    let subjectId: Int
    let subjectName: String
    let thumbnailUrl: String?
}

struct SaveAudioNoteProgressRequest: Encodable {
    let lastPositionSeconds: Int
    let playbackSpeed: Double
    let durationMinutes: Int
    let ended: Bool
}

struct SaveAudioNoteProgressPayload: Decodable {
    let history: APIAudioNotePlaybackHistory
}

struct APIAudioNotePlaybackHistory: Decodable, Hashable {
    let audioNoteId: Int
    let lastPlayedAt: Date
    let lastPositionSeconds: Int
    let playbackSpeed: Double
}
