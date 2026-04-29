import Foundation

struct FlashcardsTopicSelectionContent: Hashable {
    let title: String
    let subtitle: String
    let availableTopicsTitle: String
    let availableTopics: [Deck]
    let emptyStateMessage: String

    static func build(decks: [APIFlashcardDeckSummary]) -> FlashcardsTopicSelectionContent {
        FlashcardsTopicSelectionContent(
            title: "Flashcards",
            subtitle: "Choose a topic to start a quick recall session.",
            availableTopicsTitle: "Available Topics",
            availableTopics: decks.map(Deck.init),
            emptyStateMessage: "No flashcard decks available yet."
        )
    }
}

extension FlashcardsTopicSelectionContent {
    struct Deck: Identifiable, Hashable {
        let id: Int
        let title: String
        let subjectName: String
        let description: String?
        let cardCount: Int
        let subjectId: Int
        let topicId: Int
        let symbolName: String

        init(apiDeck: APIFlashcardDeckSummary) {
            id = apiDeck.id
            title = apiDeck.title
            subjectName = apiDeck.subjectName
            description = apiDeck.description
            cardCount = apiDeck.cardCount
            subjectId = apiDeck.subjectId
            topicId = apiDeck.topicId
            symbolName = Self.symbolName(for: apiDeck.subjectName)
        }

        var detailText: String {
            "\(subjectName) • \(cardCount) \(cardCount == 1 ? "card" : "cards")"
        }

        private static func symbolName(for subjectName: String) -> String {
            switch subjectName.lowercased() {
            case let name where name.contains("chem"):
                return "flask.fill"
            case let name where name.contains("phys"):
                return "bolt.fill"
            case let name where name.contains("bio"):
                return "leaf.fill"
            case let name where name.contains("math"):
                return "sum"
            default:
                return "rectangle.on.rectangle"
            }
        }
    }
}
