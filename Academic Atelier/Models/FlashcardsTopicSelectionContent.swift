import Foundation

struct FlashcardsTopicSelectionContent {
    var title: String
    var subtitle: String
    var availableTopicsTitle: String
    var availableTopics: [Topic]
    var recentlyPracticedTitle: String
    var recentlyPracticed: [RecentTopic]

    static let placeholder = FlashcardsTopicSelectionContent.makePlaceholder()

    static func makePlaceholder(
        availableTopics: [Topic] = [
            .init(
                id: "reaction-mechanisms",
                title: "Reaction Mechanisms",
                subjectName: "Chemistry",
                metadata: "24 cards",
                symbolName: "flask"
            ),
            .init(
                id: "cell-division",
                title: "Cell Division",
                subjectName: "Biology",
                metadata: "12 concepts",
                symbolName: "microbe"
            ),
            .init(
                id: "integration-techniques",
                title: "Integration Techniques",
                subjectName: "Mathematics",
                metadata: "quick recall set",
                symbolName: "sum"
            ),
            .init(
                id: "newtons-laws",
                title: "Newton's Laws",
                subjectName: "Physics",
                metadata: "18 cards",
                symbolName: "compass.drawing"
            )
        ],
        recentlyPracticed: [RecentTopic] = [
            .init(id: "organic-basics", deckID: "organic-basics", title: "Organic Bas...", subjectCode: "CHEM", symbolName: "clock.arrow.circlepath"),
            .init(id: "wave-optics", deckID: "wave-optics", title: "Wave Optics", subjectCode: "PHYS", symbolName: "clock.arrow.circlepath")
        ]
    ) -> FlashcardsTopicSelectionContent {
        FlashcardsTopicSelectionContent(
            title: "Flashcards",
            subtitle: "Choose a topic to start a quick recall session.",
            availableTopicsTitle: "Available Topics",
            availableTopics: availableTopics,
            recentlyPracticedTitle: "Recently Practiced",
            recentlyPracticed: recentlyPracticed
        )
    }
}

extension FlashcardsTopicSelectionContent {
    struct Topic: Identifiable, Hashable {
        var id: String
        var title: String
        var subjectName: String
        var metadata: String
        var symbolName: String

        var detailText: String {
            "\(subjectName) • \(metadata)"
        }
    }

    struct RecentTopic: Identifiable, Hashable {
        var id: String
        var deckID: String
        var title: String
        var subjectCode: String
        var symbolName: String
    }

    func sessionContent(for topic: Topic) -> FlashcardsSessionContent? {
        FlashcardsSessionContent.placeholder(forTopicID: topic.id)
    }

    func sessionContent(for recentTopic: RecentTopic) -> FlashcardsSessionContent? {
        FlashcardsSessionContent.placeholder(forTopicID: recentTopic.deckID)
    }
}
