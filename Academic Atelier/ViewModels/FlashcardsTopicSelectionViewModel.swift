import Foundation

@MainActor
final class FlashcardsTopicSelectionViewModel: ObservableObject {
    @Published private(set) var content: FlashcardsTopicSelectionContent?
    @Published private(set) var isLoading = false
    @Published private(set) var isStartingDeck = false
    @Published private(set) var startingDeckID: Int?
    @Published private(set) var errorMessage = ""
    @Published private(set) var requiresSignOut = false

    private let service: RecallToolsService

    init(service: RecallToolsService = RecallToolsService()) {
        self.service = service
    }

    func load(forceRefresh: Bool = false) async {
        guard forceRefresh || content == nil else { return }

        isLoading = true
        errorMessage = ""
        requiresSignOut = false

        defer { isLoading = false }

        do {
            let decks = try await service.getFlashcardDecks()
            content = .build(decks: decks)
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startSession(for deck: FlashcardsTopicSelectionContent.Deck) async -> FlashcardsSessionContent? {
        guard !isStartingDeck else { return nil }

        isStartingDeck = true
        startingDeckID = deck.id
        errorMessage = ""
        requiresSignOut = false

        defer {
            isStartingDeck = false
            startingDeckID = nil
        }

        do {
            let payload = try await service.startFlashcardSession(deckID: deck.id)
            return .build(payload: payload, deck: deck)
        } catch let error as APIError {
            if error.requiresSignOut {
                requiresSignOut = true
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        return nil
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
