import Foundation
import SwiftUI

@MainActor
final class FlashcardsSessionViewModel: ObservableObject {
    @Published private(set) var currentIndex = 0
    @Published private(set) var isRevealed = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false
    @Published private(set) var isCompleted = false
    @Published private(set) var knownCount = 0
    @Published private(set) var reviewAgainCount = 0

    let content: FlashcardsSessionContent

    private let service: RecallToolsService
    private var answeredCardIDs = Set<Int>()

    init(
        content: FlashcardsSessionContent,
        service: RecallToolsService = RecallToolsService()
    ) {
        self.content = content
        self.service = service
    }

    var totalCards: Int {
        content.cards.count
    }

    var currentCard: FlashcardsSessionContent.Card? {
        guard content.cards.indices.contains(currentIndex) else { return nil }
        return content.cards[currentIndex]
    }

    var displayedCardNumber: Int {
        guard totalCards > 0 else { return 0 }
        return min(currentIndex + 1, totalCards)
    }

    var cardsRemaining: Int {
        max(totalCards - displayedCardNumber, 0)
    }

    var progressValue: CGFloat {
        guard totalCards > 0 else { return 0 }
        if isCompleted { return 1 }
        return CGFloat(displayedCardNumber) / CGFloat(totalCards)
    }

    func revealAnswer() {
        isRevealed = true
    }

    func respondCurrentCard(as responseType: FlashcardResponseType) async -> Bool {
        guard let card = currentCard, !isSubmitting, !isCompleted else { return false }
        guard !answeredCardIDs.contains(card.id) else { return false }

        isSubmitting = true
        errorMessage = ""
        requiresSignOut = false

        defer { isSubmitting = false }

        do {
            let payload = try await service.respondToFlashcardSession(
                sessionID: content.sessionId,
                flashcardID: card.id,
                responseType: responseType.rawValue
            )

            answeredCardIDs.insert(card.id)
            knownCount = payload.session.knownCount
            reviewAgainCount = payload.session.reviewAgainCount
            isCompleted = payload.session.isCompleted

            if payload.session.isCompleted {
                isRevealed = true
                return true
            }

            currentIndex = min(payload.session.currentCardIndex, max(totalCards - 1, 0))
            isRevealed = false
            return false
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        return false
    }
}

private extension APIError {
    var requiresSignOut: Bool {
        switch self {
        case .missingToken, .unauthorized:
            return true
        default:
            return false
        }
    }
}
