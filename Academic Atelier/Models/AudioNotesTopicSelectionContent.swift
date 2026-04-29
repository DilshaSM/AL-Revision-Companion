import Foundation

struct AudioNotesTopicSelectionContent: Hashable {
    let title: String
    let subtitle: String
    let availableTopicsTitle: String
    let availableTopics: [Note]
    let emptyStateMessage: String

    static func build(audioNotes: [APIAudioNoteSummary]) -> AudioNotesTopicSelectionContent {
        AudioNotesTopicSelectionContent(
            title: "Audio Notes",
            subtitle: "Choose a topic to start an audio revision session.",
            availableTopicsTitle: "Available Notes",
            availableTopics: audioNotes.map(Note.init),
            emptyStateMessage: "No audio notes available yet."
        )
    }
}

extension AudioNotesTopicSelectionContent {
    struct Note: Identifiable, Hashable {
        let id: Int
        let title: String
        let subjectName: String
        let description: String?
        let durationSeconds: Int
        let topicId: Int
        let subjectId: Int
        let thumbnailURLString: String?
        let symbolName: String

        init(apiAudioNote: APIAudioNoteSummary) {
            id = apiAudioNote.id
            title = apiAudioNote.title
            subjectName = apiAudioNote.subjectName
            description = apiAudioNote.description
            durationSeconds = apiAudioNote.durationSeconds
            topicId = apiAudioNote.topicId
            subjectId = apiAudioNote.subjectId
            thumbnailURLString = apiAudioNote.thumbnailUrl
            symbolName = "headphones"
        }

        var detailText: String {
            "\(subjectName) • \(Self.durationText(for: durationSeconds))"
        }

        private static func durationText(for durationSeconds: Int) -> String {
            let minutes = max(Int(ceil(Double(max(durationSeconds, 0)) / 60.0)), 1)
            return "\(minutes) min"
        }
    }
}
