import Foundation

struct FlashcardsSessionContent: Hashable {
    let sessionId: Int
    let deckId: Int
    let topicTitle: String
    let subjectName: String
    let topicId: Int
    let cards: [Card]
    let completionMessage: String

    static func build(
        payload: FlashcardSessionStartPayload,
        deck: FlashcardsTopicSelectionContent.Deck
    ) -> FlashcardsSessionContent {
        FlashcardsSessionContent(
            sessionId: payload.sessionId,
            deckId: payload.deck.id,
            topicTitle: payload.deck.title,
            subjectName: deck.subjectName,
            topicId: deck.topicId,
            cards: payload.deck.cards
                .sorted { $0.orderIndex < $1.orderIndex }
                .map(Card.init),
            completionMessage: "Great work. Your recall session has been recorded."
        )
    }
}

extension FlashcardsSessionContent {
    struct Card: Identifiable, Hashable {
        let id: Int
        let frontLabel: String
        let frontText: String
        let backText: String
        let hintText: String

        init(apiCard: APIFlashcardCard) {
            id = apiCard.id
            frontLabel = "FLASHCARD"
            frontText = apiCard.frontText
            backText = apiCard.backText
            hintText = apiCard.hintText ?? "Recall the answer before revealing."
        }
    }
}

enum FlashcardResponseType: String {
    case knowThis = "know_this"
    case reviewAgain = "review_again"
}
