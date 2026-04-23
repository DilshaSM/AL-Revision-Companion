import Foundation

struct AudioNotesTopicSelectionContent: Hashable {
    var title: String
    var subtitle: String
    var availableTopicsTitle: String
    var availableTopics: [Topic]
    var recentAudioNotesTitle: String
    var recentAudioNotes: [RecentAudioNote]

    static let placeholder = AudioNotesTopicSelectionContent(
        title: "Audio Notes",
        subtitle: "Choose a topic to start a Audio note",
        availableTopicsTitle: "Available Topics",
        availableTopics: [
            .init(id: "genetics-inheritance", title: "Genetics & Inheritance", subjectName: "Chemistry", durationText: "12 min"),
            .init(id: "entropy-explained", title: "Entropy Explained", subjectName: "Chemistry", durationText: "24 min"),
            .init(id: "integration-techniques", title: "Integration Techniques", subjectName: "Mathematics", durationText: "10 min"),
            .init(id: "newtons-laws", title: "Newton's Laws", subjectName: "Physics", durationText: "18 min")
        ],
        recentAudioNotesTitle: "Recent Audio Notes",
        recentAudioNotes: [
            .init(id: "entropy-explained-recent", topicID: "entropy-explained", title: "Entropy Explained", subjectName: "Chemistry", durationText: "24 min")
        ]
    )
}

extension AudioNotesTopicSelectionContent {
    struct Topic: Identifiable, Hashable {
        var id: String
        var title: String
        var subjectName: String
        var durationText: String
        var symbolName: String = "headphones"

        var detailText: String {
            "\(subjectName) • \(durationText)"
        }
    }

    struct RecentAudioNote: Identifiable, Hashable {
        var id: String
        var topicID: String
        var title: String
        var subjectName: String
        var durationText: String
        var symbolName: String = "clock.arrow.circlepath"

        var detailText: String {
            "\(subjectName.uppercased()) • \(durationText.uppercased())"
        }
    }

    func detailContent(for topic: Topic) -> AudioNotesDetailContent? {
        AudioNotesDetailContent.placeholder(forTopicID: topic.id)
    }

    func detailContent(for recentAudioNote: RecentAudioNote) -> AudioNotesDetailContent? {
        AudioNotesDetailContent.placeholder(forTopicID: recentAudioNote.topicID)
    }
}
